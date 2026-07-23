#!/usr/bin/env python3
import json
import pathlib
import subprocess
import tempfile


SCRIPT = pathlib.Path(__file__).with_name("release-retention.py")


def release_parameter(release_id: str, day: int) -> dict:
    manifest = {
        "release_id": release_id,
        "created_at": f"2026-07-{day:02d}T00:00:00Z",
    }
    return {
        "Name": f"/voting/releases/{release_id}/manifest",
        "Value": json.dumps(manifest),
    }


def run_registry(parameters: list[dict], *arguments: str) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory() as directory:
        registry_path = pathlib.Path(directory) / "registry.json"
        registry_path.write_text(json.dumps({"Parameters": parameters}), encoding="utf-8")
        return subprocess.run(
            [
                "python3",
                str(SCRIPT),
                str(registry_path),
                "--keep",
                "3",
                "--incoming-release",
                "d" * 40,
                *arguments,
            ],
            check=False,
            capture_output=True,
            text=True,
        )


parameters = [
    release_parameter("a" * 40, 1),
    release_parameter("b" * 40, 2),
    release_parameter("c" * 40, 3),
]

cleanup = run_registry(parameters)
assert cleanup.returncode == 0, cleanup.stderr
assert f"/voting/releases/{'a' * 40}/manifest" in cleanup.stdout
assert f"/voting/releases/{'a' * 40}/tested/dev" in cleanup.stdout
assert f"/voting/releases/{'b' * 40}/manifest" not in cleanup.stdout

protected = run_registry(parameters, "--protected-release", "a" * 40)
assert protected.returncode == 1
assert "current release" in protected.stderr

print("Release retention tests passed.")
