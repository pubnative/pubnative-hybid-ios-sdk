#!/usr/bin/env python3

# ========================================
# 🧩 HyBid Generated Interface Swift Updater
# ========================================
# Python script that regenerates or patches the auto-generated
# Swift interface headers to maintain compatibility across
# builds and ensure correct bridging between Objective-C and Swift.
#
# 🧰 Inputs:
#   - Path to HyBid framework sources
#
# 📦 Outputs:
#   - Updated HyBid-Swift.h or related interface files
#
# 💻 Usage:
#   python3 Scripts/update-HyBid-Generated-Interface-Swift.py
#
# 🧩 Notes:
#   - Should be run after Xcode build if interface headers change.
#   - Safe to include in CI for consistency checks.
# ========================================

import re
import subprocess
from pathlib import Path
import os
import sys

# === CONFIG ===
AUTO_COMMIT = os.getenv("AUTO_COMMIT", "false").lower() == "true"

START_MARK = "// === AUTO-GENERATED SWIFT INTERFACE START ==="
END_MARK = "// === AUTO-GENERATED SWIFT INTERFACE END ==="

# === PATH DETECTION ===
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent

generated_candidates = list(PROJECT_ROOT.glob("**/HyBid-Generated-Interface-Swift.h"))
swift_candidates = (
    list(PROJECT_ROOT.glob("**/HyBid-Swift.h"))
    + list((Path.home() / "Library/Developer/Xcode/DerivedData").glob("**/HyBid-Swift.h"))
)

if not generated_candidates:
    print("❌ Could not locate HyBid-Generated-Interface-Swift.h.")
    sys.exit(1)

if not swift_candidates:
    print("❌ Could not locate HyBid-Swift.h.")
    sys.exit(1)

BASE_FILE = generated_candidates[0]
NEW_FILE = max(swift_candidates, key=lambda f: f.stat().st_mtime)
OUTPUT_FILE = BASE_FILE

print(f"📂 Project root: {PROJECT_ROOT}")
print(f"🧩 Base header: {BASE_FILE}")
print(f"🆕 Source Swift header: {NEW_FILE}")

# === EXTRACT OBJECTIVE-C REGION FROM SWIFT HEADER ===
def extract_objc_region(swift_text):
    """Extracts the Objective-C interoperability section from the last #if defined(__OBJC__) to its #endif."""
    objc_blocks = [m.start() for m in re.finditer(r"^#if\s+defined\(__OBJC__\)", swift_text, flags=re.M)]
    if not objc_blocks:
        print("❌ No #if defined(__OBJC__) block found.")
        sys.exit(1)

    start_idx = objc_blocks[-1]
    end_match = re.search(r"^#endif\b.*", swift_text[start_idx:], flags=re.M)
    if not end_match:
        print("❌ Could not find matching #endif for Objective-C region.")
        sys.exit(1)

    end_idx = start_idx + end_match.end()
    region_text = swift_text[start_idx:end_idx]
    print(
        f"🧠 Extracted Objective-C region from lines "
        f"{swift_text.count(os.linesep, 0, start_idx)+1}–{swift_text.count(os.linesep, 0, end_idx)}."
    )

    # Remove the #if defined(__OBJC__) and #endif wrappers
    region_lines = [
        line for line in region_text.splitlines()
        if not re.match(r"^#if\s+defined\(__OBJC__\)", line)
        and not re.match(r"^#endif\b", line)
    ]
    return "\n".join(region_lines).strip()

# === MAIN LOGIC ===
new_text = NEW_FILE.read_text(encoding="utf-8", errors="ignore")
base_text = BASE_FILE.read_text(encoding="utf-8", errors="ignore")

objc_region = extract_objc_region(new_text)

# ✅ Safety check: make sure we actually extracted something valid
if not objc_region.strip():
    print("❌ Error: extracted Objective-C region is empty. Aborting to avoid overwriting with blank content.")
    sys.exit(1)

# Replace only content between markers (keep header comments intact)
section_pattern = re.compile(
    rf"{re.escape(START_MARK)}(.*?){re.escape(END_MARK)}", re.DOTALL
)
match = section_pattern.search(base_text)

if not match:
    print("❌  Could not find update markers in HyBid-Generated-Interface-Swift.h")
    print("🧩  Please ensure the file contains both markers:")
    print("")
    print(f"   {START_MARK}")
    print("       // Generated Swift interface code goes here")
    print(f"   {END_MARK}")
    print("")
    print("⚠️  Add these lines to HyBid-Generated-Interface-Swift.h before running this script again.")
    sys.exit(1)
else:
    old_section = match.group(1)
    # Preserve the two comment lines if they exist
    preserved_header = re.findall(
        r"// The code between these markers is automatically managed\..*?Do NOT manually edit inside this block\.",
        old_section,
        flags=re.S,
    )
    preserved_text = (
        "\n".join(preserved_header) + "\n\n" if preserved_header else
        "// The code between these markers is automatically managed.\n"
        "// Do NOT manually edit inside this block.\n\n"
    )
    safe_region = objc_region.replace("\\", r"\\").replace("$", r"\$")
    merged_text = section_pattern.sub(
        f"{START_MARK}\n{preserved_text}{safe_region}\n{END_MARK}", base_text
    )

# Fix import path
merged_text = merged_text.replace("#import <HyBid/HyBid.h>", "#import <HyBid.h>")

OUTPUT_FILE.write_text(merged_text, encoding="utf-8")
print(f"✅ Merged Swift interface written to {OUTPUT_FILE}")

def git_commit_and_push(file_path):
    try:
        subprocess.run(["git", "add", str(file_path)], check=True)
        diff_result = subprocess.run(["git", "diff", "--cached", "--quiet", str(file_path)], check=False)
        if diff_result.returncode == 0:
            print("⚠️  No changes to commit for this file.")
            return False

        subprocess.run(["git", "commit", "-m", "chore: update Swift interfaces from new build [skip ci]"], check=True)
        print("✅ Auto-commit created for updated interface file.")

        branch = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], text=True).strip()
        subprocess.run(["git", "push", "origin", branch], check=True)
        print(f"🚀 Changes pushed successfully to branch: {branch}")
        return True

    except subprocess.CalledProcessError as e:
        print(f"⚠️  Git operation failed: {e}")
        return False

if AUTO_COMMIT:
    git_commit_and_push(BASE_FILE)
    print("🏁 Done! (Git push logic executed because AUTO_COMMIT=true.)")
else:
    print("🏁 Done! (Git push logic skipped; AUTO_COMMIT is not enabled.)")
