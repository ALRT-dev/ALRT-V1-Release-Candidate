import unittest
from unittest.mock import patch
import test_signing_access as signing


class SigningMetadataRequestTest(unittest.TestCase):
    def test_uses_existing_job_token_for_public_metadata(self):
        with patch.dict(signing.os.environ, {"GITHUB_TOKEN": "fixture-token"}):
            request = signing.github_metadata_request()
        self.assertEqual(request.full_url, "https://api.github.com/meta")
        self.assertEqual(request.get_header("Authorization"), "Bearer fixture-token")
        self.assertEqual(request.get_header("Accept"), "application/vnd.github+json")

    def test_missing_job_token_fails_before_private_key_is_written(self):
        with patch.dict(signing.os.environ, {}, clear=True):
            with self.assertRaisesRegex(SystemExit, "GitHub job token"):
                signing.github_metadata_request()


if __name__ == "__main__":
    unittest.main()
