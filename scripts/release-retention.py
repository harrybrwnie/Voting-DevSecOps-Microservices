#!/usr/bin/env python3
import argparse
import json
import pathlib
import sys


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("parameters_json", type=pathlib.Path)
    parser.add_argument("--keep", type=int, required=True)
    parser.add_argument("--incoming-release", required=True)
    parser.add_argument("--protected-release", action="append", default=[])
    args = parser.parse_args()

    response = json.loads(args.parameters_json.read_text())
    manifests = []
    for parameter in response.get("Parameters", []):
        if not parameter["Name"].endswith("/manifest"):
            continue
        manifest = json.loads(parameter["Value"])
        manifests.append(
            {
                "release_id": manifest["release_id"],
                "created_at": manifest["created_at"],
                "manifest_name": parameter["Name"],
            }
        )

    if any(item["release_id"] == args.incoming_release for item in manifests):
        return 0

    manifests.append(
        {
            "release_id": args.incoming_release,
            "created_at": "9999-12-31T23:59:59Z",
            "manifest_name": "",
        }
    )
    manifests.sort(key=lambda item: (item["created_at"], item["release_id"]))
    expired = manifests[: max(0, len(manifests) - args.keep)]
    protected = {release_id for release_id in args.protected_release if release_id}

    blocked = [item["release_id"] for item in expired if item["release_id"] in protected]
    if blocked:
        print(
            "Retention would expire an environment's current release: " + ", ".join(blocked),
            file=sys.stderr,
        )
        return 1

    for item in expired:
        release_root = item["manifest_name"].removesuffix("/manifest")
        print(f"{release_root}/manifest")
        print(f"{release_root}/tested/dev")
        print(f"{release_root}/tested/prod")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
