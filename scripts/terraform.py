"""Bridge AWS CLI browser credentials to the lab's AWS provider 5.x."""
import json
import os
from pathlib import Path
import subprocess
import sys


if __name__ == "__main__":
    exported = subprocess.run(
        ["aws", "configure", "export-credentials", "--profile", "aws-toolkit", "--format", "process"],
        capture_output=True, text=True, check=True,
    )
    credentials = json.loads(exported.stdout)
    environment = dict(os.environ)
    for source, target in [("AccessKeyId", "AWS_ACCESS_KEY_ID"), ("SecretAccessKey", "AWS_SECRET_ACCESS_KEY"), ("SessionToken", "AWS_SESSION_TOKEN")]:
        assert isinstance(credentials.get(source), str) and credentials[source], "Missing temporary AWS credentials"
        environment[target] = credentials[source]
    environment.pop("AWS_PROFILE", None)
    root = Path(__file__).resolve().parent.parent / "terraform-aws-lab"
    sys.exit(subprocess.call(["terraform", f"-chdir={root}", *sys.argv[1:]], env=environment))
