// swift-tools-version:5.9
//
// HyBid — Swift Package Manager distribution (binary).
//
// Ships prebuilt xcframeworks produced by PubnativeLite/Scripts/generate.sh. No SDK sources
// are compiled by SPM, so the CocoaPods source distribution (HyBid.podspec) is unaffected.
//
// Two mutually exclusive flavours — an app must depend on exactly ONE of these products
// (both frameworks define the same Objective-C classes):
//   • HyBid         → HyBid.xcframework        + OMSDK_Pubnativenet.xcframework
//   • HyBid-Smaato  → Smaato_HyBid.xcframework + OMSDK_Smaato.xcframework
//                     (generate.sh <smaato scheme> Smaato_HyBid)
//
// The `let` lines marked "managed" are rewritten by PubnativeLite/Scripts/package-spm-binaries.sh on
// every release — do not edit them by hand.
//
// Local verification (before the zips are uploaded):
//   HYBID_SPM_LOCAL_ARTIFACTS=1 swift package resolve
// uses Artifacts/<name>.xcframework.zip inside this package and drops any flavour whose zips
// are not all there (SPM downloads EVERY binary target in a package, even ones whose product
// the app does not use, so a half-present flavour would fail resolution with 404s).
// CI only; Xcode's GUI does not pass shell environment to manifests.

import PackageDescription
import Foundation

let hybidVersion        = "3.9.3"                                                              // managed
let hybidChecksum       = "0000000000000000000000000000000000000000000000000000000000000000" // managed
let omsdkChecksum       = "0000000000000000000000000000000000000000000000000000000000000000" // managed
let smaatoHybidChecksum = "0000000000000000000000000000000000000000000000000000000000000000" // managed
let omsdkSmaatoChecksum = "0000000000000000000000000000000000000000000000000000000000000000" // managed

let releaseBaseURL = "https://github.com/pubnative/pubnative-hybid-ios-sdk/releases/download/\(hybidVersion)"
let useLocalArtifacts = ProcessInfo.processInfo.environment["HYBID_SPM_LOCAL_ARTIFACTS"] != nil

struct Flavour {
    let product: String
    let binaries: [(name: String, checksum: String)]
}

let flavours = [
    // `import HyBid` (Swift) / `@import HyBid;` (ObjC).
    Flavour(product: "HyBid",
            binaries: [("HyBid", hybidChecksum), ("OMSDK_Pubnativenet", omsdkChecksum)]),
    // `import Smaato_HyBid` / `@import Smaato_HyBid;` (module name = generate.sh PRODUCT_NAME).
    Flavour(product: "HyBid-Smaato",
            binaries: [("Smaato_HyBid", smaatoHybidChecksum), ("OMSDK_Smaato", omsdkSmaatoChecksum)]),
]

func localPath(_ name: String) -> String { "Artifacts/\(name).xcframework.zip" }
func hasLocal(_ name: String) -> Bool {
    FileManager.default.fileExists(atPath: "\(Context.packageDirectory)/\(localPath(name))")
}

// Release: every flavour from its release URL. Local mode: only flavours fully present on disk.
let activeFlavours = useLocalArtifacts
    ? flavours.filter { $0.binaries.allSatisfy { hasLocal($0.name) } }
    : flavours

let package = Package(
    name: "HyBid",
    // Matches HyBid.podspec and the minos generate.sh compiles into the binaries
    // (HYBID_MIN_IOS, default 13.0 — the same floor as Google Mobile Ads 13.x).
    platforms: [.iOS(.v13)],
    products: activeFlavours.map { flavour in
        .library(name: flavour.product, targets: flavour.binaries.map(\.name))
    },
    targets: activeFlavours.flatMap { flavour in
        flavour.binaries.map { binary -> Target in
            useLocalArtifacts
                ? .binaryTarget(name: binary.name, path: localPath(binary.name))
                : .binaryTarget(name: binary.name,
                                url: "\(releaseBaseURL)/\(binary.name).xcframework.zip",
                                checksum: binary.checksum)
        }
    }
)
