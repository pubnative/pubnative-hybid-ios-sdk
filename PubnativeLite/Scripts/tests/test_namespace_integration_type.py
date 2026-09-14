from pathlib import Path
import re
import subprocess
import tempfile
import unittest


# https://verve.atlassian.net/browse/VMI-1717 — co-imported SDK enums and legacy source compatibility.
SCRIPTS = Path(__file__).resolve().parents[1]
SOURCE = SCRIPTS.parent / "PubnativeLite/Core/Public"


class NamespaceIntegrationTypeTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.generated = self.root / "source"
        public = self.generated / "Core/Public"
        public.mkdir(parents=True)
        for suffix in ("h", "m"):
            (public / f"NGSDK.{suffix}").write_text(
                (SOURCE / f"HyBid.{suffix}").read_text().replace("HyBid", "NGSDK")
            )
        helpers = re.findall(
            r'/((?:namespace_omsdk_smaato_only|namespace_integration_type)\.rb)',
            (SCRIPTS / "namespace.sh").read_text(),
        )
        for helper in dict.fromkeys(helpers):
            self.run_command(["ruby", str(SCRIPTS / helper), str(self.generated)])
        for name, header in (
            ("HyBid", (SOURCE / "HyBid.h").read_text()),
            ("NGSDK", (public / "NGSDK.h").read_text()),
        ):
            module = self.root / name
            module.mkdir()
            enum_match = re.search(
                r'typedef\s+NS_ENUM\s*\(\s*NSInteger\s*,\s*'
                r'(?:SDKIntegrationType|NGSDKSDKIntegrationType)\s*\)\s*\{.*?\}[^;]*;'
                r'(?:\s*typedef NGSDKSDKIntegrationType SDKIntegrationType;)?',
                header, re.S,
            )
            self.assertIsNotNone(enum_match, f"Integration type enum missing from {name}.h")
            enum = enum_match.group()
            methods = "\n".join(
                line for line in header.splitlines()
                if re.match(r'\+.*(?:getIntegrationType|setIntegrationType)', line)
            )
            (module / f"{name}.h").write_text(
                f"#import <Foundation/Foundation.h>\n{enum}\n"
                f"@interface {name} : NSObject\n{methods}\n@end\n"
            )
            (module / "module.modulemap").write_text(
                f'module {name} {{ header "{name}.h" export * }}\n'
            )

    def run_command(self, command):
        result = subprocess.run(command, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout.strip()

    def compile(self, source, language):
        path = self.root / ("client.swift" if language == "swift" else "client.m")
        path.write_text(source)
        sdk = self.run_command(["xcrun", "--sdk", "macosx", "--show-sdk-path"])
        cache = self.root / f"cache-{len(list(self.root.glob('cache-*')))}"
        if language == "swift":
            command = ["xcrun", "swiftc", "-typecheck", "-warnings-as-errors",
                       "-sdk", sdk, "-module-cache-path", str(cache)]
        else:
            command = ["xcrun", "clang", "-fsyntax-only", "-fmodules", "-Werror",
                       "-isysroot", sdk, f"-fmodules-cache-path={cache}"]
        self.run_command(command + ["-I", str(self.root), str(path)])

    def test_swift_co_imports_in_both_orders(self):
        for imports in (("HyBid", "NGSDK"), ("NGSDK", "HyBid")):
            with self.subTest(imports=imports):
                self.compile("\n".join(f"import {name}" for name in imports) + """
HyBid.setIntegrationType(.hyBid)
HyBid.setIntegrationType(.smaato)
NGSDK.setIntegrationType(.NGSDK)
NGSDK.setIntegrationType(.smaato)
let h = HyBid.getIntegrationType()
let n = NGSDK.getIntegrationType()
""", "swift")

    def test_standalone_legacy_types_cases_and_switches(self):
        for name, first in (("HyBid", "hyBid"), ("NGSDK", "NGSDK")):
            with self.subTest(module=name):
                self.compile(f"import {name}\n" + f"""
func value(_ type: SDKIntegrationType) -> Int {{
    switch type {{
    case .{first}: return 0
    case .smaato: return 1
    @unknown default: return -1
    }}
}}
{name}.setIntegrationType(.{first})
{name}.setIntegrationType(.smaato)
""", "swift")
                self.compile(f"@import {name};\n" + f"""
_Static_assert(SDKIntegrationType{name} == 0, "first raw value");
_Static_assert(SDKIntegrationTypeSmaato == 1, "Smaato raw value");
_Static_assert(sizeof(SDKIntegrationType) == sizeof(NSInteger), "storage");
int value(SDKIntegrationType type) {{
    switch (type) {{
    case SDKIntegrationType{name}: return 0;
    case SDKIntegrationTypeSmaato: return 1;
    default: return -1;
    }}
}}
""", "objc")

    def test_objc_co_imports_with_explicit_enum_types(self):
        for imports in (("HyBid", "NGSDK"), ("NGSDK", "HyBid")):
            with self.subTest(imports=imports):
                self.compile("\n".join(f"@import {name};" for name in imports) + """
void configure(void) {
    [HyBid setIntegrationType:SDKIntegrationTypeHyBid];
    [NGSDK setIntegrationType:SDKIntegrationTypeNGSDK];
    [HyBid setIntegrationType:(enum SDKIntegrationType)SDKIntegrationTypeSmaato];
    [NGSDK setIntegrationType:(NGSDKSDKIntegrationType)SDKIntegrationTypeSmaato];
}
""", "objc")

    def test_generation_preserves_smaato_default_and_setter(self):
        source = (self.generated / "Core/Public/NGSDK.m").read_text()
        self.assertRegex(source, r'static \w+ _sdkIntegrationType = SDKIntegrationTypeSmaato;')
        self.assertRegex(
            source,
            r'setIntegrationType:\(\w+\)integrationType\s*\{\s*'
            r'_sdkIntegrationType = SDKIntegrationTypeSmaato;\s*\}',
        )


if __name__ == "__main__":
    unittest.main()
