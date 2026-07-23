# Build Once, Sign Once, Promote by Digest

Tai lieu nay la runbook cho lan migration dau tien va cac lan van hanh sau do.
`shared` la ha tang persistent. `dev` la compute tam thoi co the huy moi ngay.

## Mo hinh

```text
Application PR -> CI -> merge main
  -> build/scan/push/sign mot lan
  -> immutable release manifest trong SSM
  -> promotion PR values-dev.yaml
  -> Argo CD sync voting-dev
  -> smoke test -> tested/dev + dev pointer

Manual prod approval
  -> verify release + signature + tested/dev
  -> promotion PR values-prod.yaml
  -> Argo CD sync voting-prod
  -> smoke test -> tested/prod + prod pointer
```

GitHub Actions khong chay `helm upgrade` cho application. Git luu desired state,
ECR luu artifact, SSM luu release registry, va Argo CD reconcile EKS.

## 1. Apply Shared Mot Lan

Stack nay tao ba ECR repository immutable va ba IAM role least-privilege. No doc
GitHub OIDC provider dang ton tai thay vi tao provider thu hai.

```bash
cd infra/terraform/environments/shared
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
terraform output
```

Khong chay `terraform destroy` trong thu muc `shared` khi chi muon tat EKS.

## 2. Cau Hinh GitHub

Lay ARN tu shared state:

```bash
cd infra/terraform/environments/shared
terraform output -raw release_role_arn
terraform output -raw dev_role_arn
terraform output -raw prod_role_arn
```

Repository variables:

```text
AWS_ACCOUNT_ID=911540681678
AWS_REGION=us-east-1
AWS_RELEASE_ROLE_ARN=<release_role_arn>
SSM_RELEASES_PATH=/voting/releases
PROMOTION_APP_ID=4296623
```

Environment `dev` variables:

```text
AWS_ROLE_ARN=<dev_role_arn>
EKS_CLUSTER_NAME=voting-dev-eks
K8S_NAMESPACE=voting-dev
SSM_ENV_PATH=/voting/environments/dev
HELM_VALUES_FILE=helm/voting-app/values-dev.yaml
ARGO_APPLICATION=voting-app-dev
```

Environment `prod` variables:

```text
AWS_ROLE_ARN=<prod_role_arn>
EKS_CLUSTER_NAME=voting-dev-eks
K8S_NAMESPACE=voting-prod
SSM_ENV_PATH=/voting/environments/prod
HELM_VALUES_FILE=helm/voting-app/values-prod.yaml
ARGO_APPLICATION=voting-app-prod
```

Them `PROMOTION_APP_PRIVATE_KEY` vao secret cua ca hai environment. Voi key nam
tren Windows va terminal dang la WSL:

```bash
gh secret set PROMOTION_APP_PRIVATE_KEY \
  --env dev \
  < /mnt/d/DevOps/SuperSecret/h4rry-voting-promotion-bot.private-key.pem

gh secret set PROMOTION_APP_PRIVATE_KEY \
  --env prod \
  < /mnt/d/DevOps/SuperSecret/h4rry-voting-promotion-bot.private-key.pem
```

Sau khi release dev va prod dau tien thanh cong, xoa repository-level
`PROMOTION_APP_PRIVATE_KEY`, cac AWS secret cu, va role
`github-actions-ecr-role`. Khong xoa GitHub OIDC provider dang duoc shared stack
tham chieu.

## 3. Apply EKS

Shared stack phai ton tai truoc vi dev remote state can ARN cua dev/prod role.

```bash
cd infra/terraform/environments/dev
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

Cap nhat kubeconfig:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name voting-dev-eks
```

## 4. Bootstrap Argo CD

Terraform cai Argo CD, nhung Application objects duoc bootstrap mot lan sau moi
lan cluster duoc tao lai:

```bash
kubectl apply -f argocd/applications/voting-app-dev.yaml
kubectl apply -f argocd/applications/voting-app-prod.yaml
kubectl get applications -n argocd
```

Hai values file ban dau dung zero digest nen workload application chua the pull
image. Lan merge cutover dau tien tao release that va promotion PR thay cac gia
tri nay. Day la trang thai bootstrap du kien.

## 5. Kiem Tra Dev

Sau khi application change duoc merge vao `main`, theo doi workflow
`Release - Build Once and Promote Dev`. Khi workflow thanh cong:

```bash
kubectl get application voting-app-dev -n argocd
kubectl get pods -n voting-dev
kubectl get deployment vote result worker -n voting-dev \
  -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.spec.template.spec.containers[0].image}{"\n"}{end}'

aws ssm get-parameter \
  --name /voting/environments/dev/current-release \
  --query Parameter.Value \
  --output text
```

Image reference phai co dang `repository@sha256:...`, khong phai `:latest`.

Neu release workflow bao co partial SHA tags nhung chua co manifest, dung
credential admin de xoa day du ca ba tag truoc khi rerun. Workflow release co y
khong co quyen delete ECR image:

```bash
RELEASE_ID=<full-40-character-sha>
for SERVICE in vote result worker; do
  aws ecr batch-delete-image \
    --repository-name "voting-${SERVICE}" \
    --image-ids imageTag="${RELEASE_ID}"
done
```

Chi cleanup khi SSM parameter
`/voting/releases/<release-id>/manifest` khong ton tai. Khong dung procedure nay
voi release da duoc register. ECR tu dong don reference artifacts cua subject
image da xoa trong vong 24 gio; neu Cosign van thay artifact cu, doi cleanup hoan
tat roi moi rerun.

## 6. Promote Prod Va Rollback

Trong GitHub Actions, chay `Promote Existing Release to Production`, nhap full
40-character release SHA, va approve environment `prod`. Workflow chi doc
artifact da co; no khong build hoac push image.

Rollback cung chay workflow prod voi release ID cu con trong 20 release va da co
marker `tested/dev`.

## 7. Daily Destroy Va Recreate

Cuoi ngay:

```bash
cd infra/terraform/environments/dev
terraform destroy
```

Len lai:

```bash
cd infra/terraform/environments/dev
terraform apply
aws eks update-kubeconfig --region us-east-1 --name voting-dev-eks
kubectl apply -f ../../../../argocd/applications/voting-app-dev.yaml
kubectl apply -f ../../../../argocd/applications/voting-app-prod.yaml
```

ECR images, Cosign signatures, IAM delivery roles va SSM release metadata van
ton tai vi chung thuoc `shared`. Argo CD se doc `main` va khoi phuc desired state
sau khi hai Application objects duoc bootstrap.
