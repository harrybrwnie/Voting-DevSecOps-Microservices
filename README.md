# Voting DevSecOps Microservices

A DevSecOps-oriented microservices voting application built to practice containerization, CI/CD, security scanning, infrastructure as code, Kubernetes deployment, and observability.

This project is based on a simple voting system, but extends it with a DevSecOps workflow using Docker, GitHub Actions, Trivy, SonarCloud, AWS ECR, Terraform, Helm, Prometheus, and Grafana.

---

## Architecture

The application is composed of five main services:

| Service | Technology | Description |
|---|---|---|
| `vote` | Python Flask | Web UI for submitting votes. Votes are pushed into Redis. |
| `redis` | Redis | Queue/cache layer used to temporarily store incoming votes. |
| `worker` | .NET | Background worker that consumes votes from Redis and writes them to PostgreSQL. |
| `db` | PostgreSQL | Stores voting results. |
| `result` | Node.js, Express, Socket.IO | Displays real-time voting results from PostgreSQL. |

Basic request flow:

```text
User
  |
  v
vote service
  |
  v
Redis queue
  |
  v
worker service
  |
  v
PostgreSQL
  |
  v
result service
```

---

## What This Project Covers

### Microservices

The project includes multiple services written in different languages:

- Python Flask vote service
- Node.js result service
- .NET worker service
- Redis
- PostgreSQL

The `vote` service receives votes and pushes them into Redis. The `worker` service consumes votes from Redis and stores them in PostgreSQL. The `result` service reads from PostgreSQL and displays the current voting result.

---

### Docker and Docker Compose

All application services are containerized and can be started locally with Docker Compose.

```bash
docker compose up -d --build
```

Local application URLs:

| Service | URL |
|---|---|
| Vote UI | http://localhost:5000 |
| Result UI | http://localhost:5001 |

The Docker Compose stack includes:

- `vote`
- `result`
- `worker`
- `redis`
- `db`

Stop the stack:

```bash
docker compose down -v
```

---

### Local Observability with Prometheus and Grafana

A local monitoring stack is included using Docker Compose.

Monitoring services:

| Service | Purpose |
|---|---|
| Prometheus | Scrapes and stores metrics |
| Grafana | Visualizes metrics |
| Redis Exporter | Exposes Redis metrics |
| Postgres Exporter | Exposes PostgreSQL metrics |
| cAdvisor | Exposes container-level CPU and memory metrics |

Start the application with monitoring:

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d --build
```

Monitoring URLs:

| Tool | URL |
|---|---|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| cAdvisor | http://localhost:8080 |

Default Grafana login:

```text
username: admin
password: admin
```

Prometheus scrape targets include:

- `vote:80/metrics`
- `result:4000/metrics`
- `redis-exporter:9121`
- `postgres-exporter:9187`
- `cadvisor:8080`

Stop the full stack:

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml down -v
```

---

## Application Metrics

The `vote` service exposes Prometheus metrics through `prometheus-flask-exporter`.

Custom vote metric:

```promql
vote_submissions_total
```

The `result` service uses `prom-client` and exposes a custom HTTP request counter:

```promql
result_http_requests_total
```

Useful PromQL queries:

```promql
up
```

```promql
vote_submissions_total
```

```promql
rate(result_http_requests_total[1m])
```

```promql
container_memory_usage_bytes
```

```promql
rate(container_cpu_usage_seconds_total[1m])
```

---

## Grafana Dashboard as Code

Grafana provisioning is defined in code.

The repository includes:

```text
monitoring/grafana/provisioning/datasources/datasource.yml
monitoring/grafana/provisioning/dashboards/dashboard.yml
monitoring/grafana/dashboards/voting-observability.json
```

This means Grafana automatically provisions:

- Prometheus datasource
- Voting App dashboard
- Panels for service health, HTTP request rate, vote submissions, and container metrics

No manual dashboard creation is required.

---

## CI/CD Pipeline

The project uses GitHub Actions with modular reusable workflows.

### CI

CI runs on pull requests to `main`.

CI includes:

- Secret scanning
- Source vulnerability scanning
- Code quality scanning
- Docker build
- Docker image vulnerability scanning
- Docker Compose smoke testing
- Helm chart validation

Main CI workflow:

```text
.github/workflows/ci.yml
```

Reusable workflows include:

```text
.github/workflows/reusable-secret-scan.yml
.github/workflows/reusable-source-scan.yml
.github/workflows/reusable-code-quality.yml
.github/workflows/reusable-docker-ci.yml
.github/workflows/reusable-helm-validate.yml
```

The Docker CI workflow builds images, scans them using Trivy, starts the application with Docker Compose, and tests the `vote` and `result` services.

---

### Release and Promotion

Application changes merged to `main` run `.github/workflows/release.yml`.
The workflow builds the three application images once, scans them, publishes
full commit SHA tags, signs their immutable digests with Cosign, and stores an
immutable release manifest in SSM Parameter Store.

Dev promotion is automatic and production promotion is manually approved
through `.github/workflows/promote-prod.yml`. Both promotions update Git through
a GitHub App; Argo CD is the only component that applies application resources
to EKS.

See [DELIVERY.md](DELIVERY.md) for bootstrap, migration, daily operations, and
rollback commands.

---

## AWS Infrastructure as Code

Terraform is split by lifecycle:

```text
infra/terraform/environments/shared
infra/terraform/environments/dev
```

The persistent `shared` stack owns ECR and the least-privilege GitHub Actions
roles. The ephemeral `dev` stack owns the VPC, one EKS cluster, Argo CD,
monitoring, and isolated `voting-dev` and `voting-prod` namespaces. Daily
destroy operations target only the `dev` stack.

The EKS module uses the official `terraform-aws-modules/eks/aws` module and configures:

- EKS cluster
- Managed node group
- EKS addons
- Node IAM permissions
- EBS CSI driver policy

---

## Kubernetes and Helm

The project includes a Helm chart for deploying the application to Kubernetes/EKS.

Helm chart path:

```text
helm/voting-app
```

The chart defines Kubernetes resources for:

- vote service
- result service
- worker service
- Redis
- PostgreSQL

Default image registry:

```text
911540681678.dkr.ecr.us-east-1.amazonaws.com
```

Default namespace:

```text
voting-dev
```

Validate the Helm chart:

```bash
helm lint ./helm/voting-app
```

Render Kubernetes manifests:

```bash
helm template voting-app ./helm/voting-app --namespace voting-dev
```

Application deployment is owned by Argo CD. Bootstrap its Applications after
creating the cluster:

```bash
kubectl apply -f argocd/applications/voting-app-dev.yaml
kubectl apply -f argocd/applications/voting-app-prod.yaml
```

---

## Local Development

### Requirements

- Docker
- Docker Compose
- Git
- Optional: AWS CLI
- Optional: Terraform
- Optional: kubectl
- Optional: Helm

### Run Application Locally

```bash
docker compose up -d --build
```

Check services:

```bash
docker compose ps
```

Open:

```text
Vote UI:   http://localhost:5000
Result UI: http://localhost:5001
```

Stop:

```bash
docker compose down -v
```

### Run with Monitoring

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d --build
```

Open:

```text
Prometheus: http://localhost:9090
Grafana:    http://localhost:3000
cAdvisor:   http://localhost:8080
```

Stop:

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml down -v
```

---

## Security and DevSecOps Practices

This project currently includes:

- Secret scanning in CI
- Filesystem vulnerability scanning
- Docker image vulnerability scanning
- Code quality scanning
- Non-root users in application containers
- Multi-stage Docker builds
- GitHub Actions OIDC for AWS authentication
- ECR image publishing
- Helm chart validation
- Local observability with Prometheus and Grafana
- Dashboard provisioning as code

---

## Current Status

Completed:

- Microservices application
- Docker Compose local environment
- Multi-service containerization
- GitHub Actions CI
- Trivy vulnerability scanning
- SonarCloud code quality workflow
- Build-once release and digest promotion workflows
- AWS OIDC authentication for GitHub Actions
- Terraform modules for AWS infrastructure
- Helm chart for Kubernetes deployment
- Local Prometheus and Grafana monitoring
- Grafana dashboard provisioning as code

In progress:

- First shared-stack migration and end-to-end release verification
- Adding `ServiceMonitor` resources for application metrics
- Provisioning Grafana dashboards inside EKS

---

## Roadmap

Planned improvements:

- Add `ServiceMonitor` for `vote` and `result`
- Add Grafana dashboard ConfigMap for Kubernetes monitoring
- Add Kubernetes readiness and liveness probes
- Add resource requests and limits
- Move hardcoded credentials to Kubernetes Secrets or external secret management
- Add integration tests for the full voting flow

---

## Notes

This is a learning-oriented DevSecOps project. It is not intended to be production-ready yet. Some configurations, such as local database credentials and simple service settings, are currently optimized for lab and development usage.

The main purpose of this project is to demonstrate the DevOps/DevSecOps workflow around a microservices application:

```text
Code
  -> Build
  -> Scan
  -> Test
  -> Push image
  -> Deploy with Helm
  -> Monitor with Prometheus and Grafana
```
