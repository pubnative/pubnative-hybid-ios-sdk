from pathlib import Path
import subprocess
import tempfile
import unittest


# https://verve.atlassian.net/browse/VMI-1753 — release branch checkout used by Step 1 (public source) and Step 2b (SPM).
SCRIPT = Path(__file__).resolve().parents[1] / "checkout-release-branch.sh"


class CheckoutReleaseBranchTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.origin = root / "origin"
        self.clone = root / "clone"
        self.git("init", "-q", "-b", "main", str(self.origin))
        self.git("commit", "-q", "--allow-empty", "-m", "Release 3.9.1", cwd=self.origin)
        self.git("tag", "3.9.1", cwd=self.origin)
        self.git("commit", "-q", "--allow-empty", "-m", "Release 3.9.2", cwd=self.origin)
        self.git("tag", "3.9.2", cwd=self.origin)
        self.git("branch", "-q", "release/hybid-3.8", "3.9.1", cwd=self.origin)
        self.git("clone", "-q", str(self.origin), str(self.clone))

    def tearDown(self):
        self.tmp.cleanup()

    def git(self, *args, cwd=None):
        return subprocess.run(
            ["git", "-c", "user.name=test", "-c", "user.email=test@example.com", *args],
            cwd=cwd, check=True, text=True, capture_output=True,
        ).stdout.strip()

    def checkout(self, *args):
        return subprocess.run([str(SCRIPT), *args], cwd=self.clone, text=True, capture_output=True)

    def head(self):
        return self.git("rev-parse", "--abbrev-ref", "HEAD", cwd=self.clone), self.git("rev-parse", "HEAD", cwd=self.clone)

    def test_checks_out_an_existing_origin_branch_at_its_tip(self):
        for branch in ("main", "release/hybid-3.8"):
            with self.subTest(branch=branch):
                result = self.checkout(branch, "3.9.1")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.head(), (branch, self.git("rev-parse", branch, cwd=self.origin)))

    def test_existing_origin_branch_wins_over_a_stale_local_branch(self):
        self.git("branch", "-q", "release/hybid-3.8", "3.9.2", cwd=self.clone)
        result = self.checkout("release/hybid-3.8", "3.9.1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.head(), ("release/hybid-3.8", self.git("rev-parse", "3.9.1", cwd=self.origin)))

    def test_creates_a_missing_branch_from_the_base_tag(self):
        result = self.checkout("release/hybid-3.9", "3.9.1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Creating release/hybid-3.9 from tag 3.9.1", result.stdout)
        self.assertEqual(self.head(), ("release/hybid-3.9", self.git("rev-parse", "3.9.1", cwd=self.origin)))

    def test_fails_when_the_branch_is_missing_and_no_base_tag_is_given(self):
        before = self.head()
        for args in (("release/hybid-3.9",), ("release/hybid-3.9", "")):
            with self.subTest(args=args):
                result = self.checkout(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("no base tag to create release/hybid-3.9 from", result.stderr)
                self.assertEqual(self.head(), before)


if __name__ == "__main__":
    unittest.main()
