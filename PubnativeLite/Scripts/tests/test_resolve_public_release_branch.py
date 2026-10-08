from pathlib import Path
import subprocess
import unittest


# https://verve.atlassian.net/browse/VMI-1722 — releasing an older line never moves public main backwards.
SCRIPT = Path(__file__).resolve().parents[1] / "resolve-public-release-branch.sh"
PUBLIC_TAGS = "3.7.1\n3.8.0\n3.8.1\n3.9.0\n3.9.1\n3.9.2-beta1\n"


class ResolvePublicReleaseBranchTests(unittest.TestCase):
    def resolve(self, version, main_version, tags=PUBLIC_TAGS):
        return subprocess.run(
            [str(SCRIPT), version, main_version],
            input=tags, text=True, capture_output=True,
        )

    def test_newer_or_equal_version_goes_to_main(self):
        for version in ("3.9.2", "3.10.0", "3.9.1"):
            with self.subTest(version=version):
                result = self.resolve(version, "3.9.1")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.split(), ["main"])

    def test_older_version_is_redirected_to_its_release_branch(self):
        result = self.resolve("3.8.2", "3.9.1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.split(), ["release/hybid-3.8", "3.8.1"])

    def test_base_tag_is_the_newest_older_release(self):
        result = self.resolve("3.7.5", "3.9.1", tags="3.6.1\n3.9.1\n3.9.2-beta1\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.split(), ["release/hybid-3.7", "3.6.1"])

    def test_reads_all_tags_so_a_slow_tag_producer_is_never_broken_piped(self):
        result = subprocess.run(
            ["bash", "-eo", "pipefail", "-c",
             f'(sleep 0.3; printf "%s" "$1") | "{SCRIPT}" 3.9.2 3.9.1', "_", PUBLIC_TAGS],
            text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.split(), ["main"])

    def test_fails_without_an_older_release_tag_or_valid_versions(self):
        for version, main_version, error in (
            ("3.5.1", "3.9.1", "No public release tag older than 3.5.1"),
            ("3.8.2", "", "Expected an X.Y.Z version, got ''"),
            ("3.8.2-beta1", "3.9.1", "Expected an X.Y.Z version, got '3.8.2-beta1'"),
        ):
            with self.subTest(version=version, main_version=main_version):
                result = self.resolve(version, main_version)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, "")
                self.assertIn(error, result.stderr)


if __name__ == "__main__":
    unittest.main()
