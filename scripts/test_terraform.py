import io
import json
import os
from pathlib import Path
import runpy
from types import SimpleNamespace
import unittest
from unittest.mock import patch


class TerraformCredentialTests(unittest.TestCase):
    def test_temporary_credentials_are_passed_only_to_child_environment(self):
        credentials = {"AccessKeyId": "test-id", "SecretAccessKey": "test-secret", "SessionToken": "test-token"}
        result = SimpleNamespace(stdout=json.dumps(credentials))
        original_environment = dict(os.environ)
        output = io.StringIO()
        script = Path(__file__).with_name("terraform.py")
        with patch("sys.argv", [str(script), "version"]), patch("sys.stdout", output), patch("subprocess.run", return_value=result), patch("subprocess.call", return_value=0) as child:
            with self.assertRaises(SystemExit) as exit_result:
                runpy.run_path(str(script), run_name="__main__")
        self.assertEqual(exit_result.exception.code, 0)
        environment = child.call_args.kwargs["env"]
        self.assertEqual(environment["AWS_ACCESS_KEY_ID"], "test-id")
        self.assertEqual(environment["AWS_SECRET_ACCESS_KEY"], "test-secret")
        self.assertEqual(environment["AWS_SESSION_TOKEN"], "test-token")
        self.assertEqual(dict(os.environ), original_environment)
        self.assertNotIn("test-secret", output.getvalue())


if __name__ == "__main__":
    unittest.main()
