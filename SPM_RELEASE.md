# Swift Package Manager release guide

HyBid is distributed through Swift Package Manager as **prebuilt binaries**: the `HyBid.xcframework` built by `generate.sh`, plus the OMSDK xcframework it links against. SPM compiles no SDK sources, so the CocoaPods source distribution (`HyBid.podspec`) works as before. A binary package was chosen over a source package because SwiftPM can't build targets that mix Swift and Objective‑C, and HyBid's sources mix both in the same modules.

## Files

| File | Purpose |
|---|---|
| `Package.swift` | Two products. An app must use exactly one: **`HyBid`** (`HyBid` + `OMSDK_Pubnativenet`) or **`HyBid-Smaato`** (`Smaato_HyBid` + `OMSDK_Smaato`). Both are remote `.binaryTarget`s on this repo's GitHub releases. Five `// managed` lines hold the version and the four checksums; never edit them by hand. |
| `PubnativeLite/Scripts/generate.sh` | Builds the xcframework. It now also applies the minimum iOS version (`HYBID_MIN_IOS`, default 13.0), turns code coverage off, uses standard Release optimisation, and checks every slice before finishing (see below). |
| `PubnativeLite/Scripts/package-spm-binaries.sh` | Zips one xcframework per archive, computes the SPM checksums (SHA-256, identical to `swift package compute-checksum`), optionally code-signs, and rewrites that flavour's managed lines in `Package.swift`. Run it once per flavour. `--help` lists every option. |

## For integrators

In Xcode, go to **File › Add Package Dependencies…**, enter `https://github.com/pubnative/pubnative-hybid-ios-sdk` and add **one** of the two products. Or in a `Package.swift`:

```swift
.package(url: "https://github.com/pubnative/pubnative-hybid-ios-sdk", from: "3.9.3"),
// …
.product(name: "HyBid", package: "pubnative-hybid-ios-sdk"),
```

Then use `import HyBid` (Swift) or `@import HyBid;` (ObjC). The Smaato flavour uses `Smaato_HyBid` as its module name.

> The checksums in `Package.swift` are placeholders until the first SPM release is packaged and uploaded. Until then, resolving the package fails.

## Release flow

`generate.sh` needs the project's Ruby gems (`bundle install`) because it pipes `xcodebuild` output through `bundle exec xcpretty`.

```bash
./PubnativeLite/Scripts/generate.sh
```

```bash
./PubnativeLite/Scripts/generate.sh <smaato-scheme> Smaato_HyBid
```

```bash
./PubnativeLite/Scripts/package-spm-binaries.sh --version 3.9.3 --manifest Package.swift --sign-identity <SHA-1> --require-signature
```

```bash
./PubnativeLite/Scripts/package-spm-binaries.sh --version 3.9.3 --hybid Smaato_HyBid.xcframework --manifest Package.swift --sign-identity <SHA-1> --require-signature
```

```bash
gh release upload 3.9.3 spm-artifacts/*.xcframework.zip
```

1. **Build.** The two `generate.sh` runs write `HyBid.xcframework` and `Smaato_HyBid.xcframework` to the repo root. The Smaato scheme exists only in the private repo.
2. **Package.** The two `package-spm-binaries.sh` runs package each flavour into `spm-artifacts/`, and `checksums.txt` keeps all four entries. For a `Smaato_*` framework the script picks `OMSDK_Smaato.xcframework` automatically. If the first run changes the version, the script warns that the other flavour's checksums are stale until its own run finishes.
3. **Upload.** `gh release upload` attaches all four zips to the release whose tag matches `hybidVersion` in `Package.swift`.
4. **Publish.** Commit `Package.swift` with the new checksums, then tag the version. The tag must point at the commit with the right checksums.

Run step 2 before `package-private-framework.sh`. Neither script modifies its inputs.

### What `generate.sh` guarantees

- **Minimum iOS.** `HYBID_MIN_IOS` sets the minimum (default `13.0`, the same floor as Google Mobile Ads 13.x).
  - Xcode 16+ rejects deployment targets below its SDK floor (15.0 on Xcode 26/27), even though its compilers still support them. Below the floor, the script passes the floor as `IPHONEOS_DEPLOYMENT_TARGET` and makes the compilers target the real minimum with `LLVM_TARGET_TRIPLE_OS_VERSION`.
  - Afterwards it sets each framework's `MinimumOSVersion`, and fails unless every slice records the expected minimum. The arm64 simulator slice is allowed 14.0, its lowest.
- **No coverage instrumentation.** It forces `ENABLE_CODE_COVERAGE=NO` (the HyBid scheme enables coverage for tests), and fails if any slice contains `__llvm_prf_*` sections.
- **Optimised.** It uses `GCC_OPTIMIZATION_LEVEL=s`, `SWIFT_OPTIMIZATION_LEVEL=-O` and whole-module optimisation. Before this change the script forced `-O0`/`-Onone`.

### Code signing

Signing happens on the staged copy before zipping, so each checksum covers the signature.

- `--sign-identity`, or the `HYBID_CODESIGN_IDENTITY` env var, takes an "Apple Distribution" or "Developer ID Application" identity. A SHA-1 hash is the safest form; names are resolved to their SHA-1 internally, because `codesign` reports "ambiguous" when a revoked certificate shares the name.
- `--keychain`, or `HYBID_CODESIGN_KEYCHAIN`, points CI at a temporary keychain.
- `--require-signature` makes the run fail when no identity is given. Use it in release CI.
- `--no-timestamp` is for offline tests only.
- The script checks the identity before doing any work, warns about development certificates, verifies each signature with `codesign --verify --strict`, and prints the signer, team and timestamp.
- **OMSDK is left as Verve receives it**, with a warning if it's unsigned, because re-signing would replace IAB's identity with Verve's. Pass `--sign-omsdk` only if Verve decides to vouch for it.
- If an input was already signed and packaging changed it (the `-beta` version fix-up), the script stops rather than ship a broken signature. Pass `--sign-identity` to re-sign.
- Keep the signing identity the same across releases. Xcode warns integrators when a dependency's signer changes.

### Testing a release before uploading

Pass `--local` to `package-spm-binaries.sh` to also copy the zips into `Artifacts/` next to `Package.swift`. With `HYBID_SPM_LOCAL_ARTIFACTS=1` set, the manifest uses those zips instead of the release URLs. It includes only flavours whose zips are **all** present, because SPM downloads every binary target in a package, even ones whose product the app doesn't use. A half-present flavour would fail with 404s.

```bash
HYBID_SPM_LOCAL_ARTIFACTS=1 xcodebuild -scheme <consumer> -destination 'generic/platform=iOS' build
```

SwiftPM caches manifest output, so pass `--manifest-cache none`, or delete `.build/`, when the set of local zips changes. Local mode works only from the command line, because Xcode's GUI doesn't pass shell environment to manifests. `Artifacts/`, `spm-artifacts/`, `.build/` and `.swiftpm/` are git-ignored.

## Verified on Xcode 27.2 (local runs, not a published release)

- **`generate.sh` end to end**, with `xcpretty` replaced by a pass-through because bundler isn't installed on the test machine:
  - Device and simulator builds succeeded.
  - Minimum iOS 13.0 on device and x86_64 simulator, 14.0 on arm64 simulator, and `MinimumOSVersion` 13.0.
  - No coverage instrumentation, and no `-Onone`/`-O0` in the build log.
  - The existing `.swiftinterface` clean-up and `sanitize_xcframework_paths.sh` steps still pass.
  - The device binary went from 5.57 MB to 3.65 MB after removing coverage and enabling optimisation.
- **Packaging.** Each zip has one xcframework at its root, and the checksums match `swift package compute-checksum`. Packaging the same framework twice gives the same checksum. Both flavours share one manifest without overwriting each other's lines, and mismatched framework pairs are rejected.
- **Consumer.** A package with a Swift target (`import HyBid`, `HyBid.sdkVersion()`, `HyBidInterstitialAd`) and an ObjC target (`@import HyBid;`) built for device and simulator against the local zips, with `.iOS(.v13)`. `HyBid.framework` and `OMSDK_Pubnativenet.framework` are linked via `@rpath` and embedded.
- **Real app on the iOS Simulator (iPhone 17 Pro, iOS 27.2).** A plain UIKit app added the `HyBid` product through an Xcode package reference to the local package (local mode, zips from the edited `generate.sh`: iOS 13 minimum, optimised, no coverage). It was installed, launched and run:
  - Both `HyBid.framework` and `OMSDK_Pubnativenet.framework` are embedded in the app bundle, and OMSDK loads at runtime.
  - `HyBid.sdkVersion()` returns 3.9.3, and the framework reports `MinimumOSVersion` 13.0.
  - All 11 checked resources resolve through `Bundle(for:)`: the four `.js` files including `omsdk.js`, the privacy manifest, three nibs, the storyboard and two images. `HyBidInternalWebBrowser.storyboard` instantiates.
  - `HyBid.initWithAppToken` (demo app token from `PNLiteDemoSettings.m`, test mode on) completed with `success=true`.
  - **Banner** (zone 2, 320×50): loaded, rendered on screen, and tracked an impression.
  - **Interstitial** (zone 4): loaded and showed a Verve test creative full-screen, with the SDK's close button and call-to-action bar. It tracked an impression and dismissed through the close button with the `interstitialDidDismiss` callback.
  - **Rewarded** (zone 4; zones 1–3 don't serve rewarded): loaded and shown full-screen with the SDK's 25-second countdown, then the close button. It tracked an impression, `onReward` fired, and `rewardedDidDismiss` fired on close.
  - **Native** (zone 1) via `HyBidNativeAdLoader`: loaded with title "Verve Group", CTA "Click" and rating 4, then `fetchAssets` completed.
    - `HyBidNativeAdRenderer` filled the icon, title, body, the SDK's `HyBidStarRatingView` (4 stars), the banner image, the content-info badge (a bundled image), and the CTA button title.
    - `startTrackingView` reported the impression. Tapping the card tracked a click and opened the advertiser landing page in Safari.
    - Integration note, not an SDK or SPM issue: a `UIButton` used as `callToActionView` takes the tap itself, so the card's tap recogniser never sees it. Tapping elsewhere on the card triggers the click. Pass the button in `startTrackingView(_:withClickableViews:with:)` if it should be clickable.
  - **VAST video** (interstitial), using Verve's own fixture `PubnativeLiteTests/EndCard/AdResponse.json` through `prepareAdWithAdReponse(adReponse:)`:
    - The SDK's media-file picker chose the MP4 and `PNLiteVASTPlayerViewController` played it, with skip control, mute toggle, progress bar and SKOverlay.
    - The full VAST event sequence was sent: `creativeView`, `start`, `firstQuartile`, `midpoint`, `thirdQuartile`, `complete`, plus impressions.
    - The fixture's custom end card then showed with a close countdown, and closing fired `interstitialDidDismiss`.
    - Environment note: the fixture's media host was too slow to stream from the test Mac (even `curl` got 50–450 KB in 30 s, and a bare `AVPlayer` with no SDK buffered 0 s). So the playback run served the same Verve video from a local range-capable HTTP server, with only the four `MediaFile` URLs changed. The stall reproduced identically with the unoptimised build, so it isn't related to the optimisation change.
  - **Rewarded VAST video**, using the same fixture through `HyBidRewardedAd.prepareAdWithAdReponse(adReponse:)` with local media:
    - Full playback sent `creativeView`, `start`, all quartiles and `complete`.
    - The ▶| control after completion opened the custom end card (an SDK MRAID view).
    - Closing it fired `onReward` and then `rewardedDidDismiss`.
  - **MRAID**, using a self-written MRAID test creative through the SDK's custom-markup API (`prepareCustomMarkup(from:with:)` / `prepareCustomMarkupFrom(_:)`):
    - The SDK injected `mraid.js` and the creative saw MRAID **3.0**, the `ready` and `viewableChange` events, the correct `getPlacementType()` (`inline` for 300×250, `interstitial` full-screen) and `getMaxSize()`.
    - 300×250: `mraid.expand()` presented the SDK's expanded modal (`state→expanded`, SDK close control), and `mraid.close()` collapsed it back into the slot (`state→default`, "MRAID did close").
    - Interstitial: `mraid.close()` dismissed the ad and fired `interstitialDidDismiss`.
    - **Resize** (300×250 → 300×400): `mraid.setResizeProperties()` + `mraid.resize()` gave `state→resized`, `sizeChange` 300×400 and the correct `getCurrentPosition()` (51,582 300×400). `mraid.close()` went through the SDK's `closeFromResize` back to `state→default` and `size→300x250`.
    - Testing note: one Expand tap in a run without console capture showed no visible change. In the captured runs every Expand and Close tap was processed, and the SDK log confirms `mraid://expand` and `mraid://close`. That first miss was most likely screenshot timing and wasn't reproduced.
  - **Clicks and landing flows:**
    - *Banner click* (live zone 2): tracked, with click beacons sent; the landing page opened externally in Safari.
    - *Interstitial click* (live zone 4): the same.
    - *Internal browser*: with the fixture's `remoteconfigs.jsondata.navigation_mode` set to `"internal"`, a video click-through opened **HyBid's in-app browser** (the `HyBidInternalWebBrowser` storyboard bundled in the SPM framework). The video sent `pause`, and after ✓ it sent `resume` and finished. The companion and custom end cards followed, and close fired `interstitialDidDismiss`.
    - *App Store / SKAdNetwork*: a click on the video fixture that carries SKAdNetwork data presented Apple's in-app store sheet (`SKStoreProductViewController`), and the video resumed after the sheet was dismissed. On the simulator the sheet shows "Cannot Connect to iTunes Store", and AdAttributionKit impressions fail with "feature is not supported". Store content and attribution need a real device.
  - **More MRAID calls**, on the full-screen MRAID ad:
    - `mraid.open()` tracked a click and opened the URL in Safari.
    - `mraid.playVideo()` handed the MP4 to the system, and it played in Safari's player.
    - `mraid.storePicture()` saved the image to the photo library once the app had been granted photo-library access (the simulator photo count went 6 → 7).
  - **Leaderboard** on the iPad Air simulator: `HyBidAdView(size: .size_728x90)` filled from zone 2 (zone 1 doesn't serve it), rendered at 728×90 and tracked an impression.
  - No crashes from the SDK in any run. The one crash during testing came from the test app itself, which instantiated an SDK nib without the owner object the SDK provides.
- **Signing.**
  - Signed with an Apple Development identity plus a secure timestamp. The signature verifies after unzipping, and survives SPM's extraction.
  - Ad-hoc signing and the env-var identity work.
  - Rejected as intended: an unknown identity, a revoked one, missing-identity combinations, and a pre-signed input that packaging changed.
- **Repo layout.** The root manifest resolves to this repo's release URLs, `HyBid.xcworkspace` still lists its schemes with `Package.swift` beside it, and the podspec still parses.

## Open items and caveats

- **Only partly runtime-tested.** The optimised SPM build was run on the iOS 27.2 Simulator only, covering banner, HTML interstitial, rewarded (HTML and VAST video), native, leaderboard (iPad), VAST video with end cards, clicks on banner, interstitial, native and video (Safari, in-app browser and App Store sheet), and MRAID expand/resize/close/open/playVideo/storePicture, as above. Still untested:
  - a physical device;
  - iOS 13 or 14 (Xcode 16+ can't run or debug them, so this needs real devices);
  - real App Store content, SKAdNetwork / AdAttributionKit attribution and SKOverlay behaviour (simulator limits);
  - the app installed from the remote GitHub release URLs, as opposed to local zips.

  Optimisation occasionally exposes latent bugs, so run the full ad-format regression before release.
- **`LLVM_TARGET_TRIPLE_OS_VERSION` is an undocumented Xcode build setting.** Re-check it with each new Xcode; the `minos` check in `generate.sh` fails loudly if it stops working.
- **Building inside the Xcode app.** The project now declares iOS 13.0, below Xcode 16+'s floor, so building the demo app or tests in the IDE still needs ≥ 15 or the same override. `generate.sh` handles release builds.
- **Not a thin repo.** With `Package.swift` at this repo's root, every SPM install clones the whole repository, about 69 MB. A thin separate package repo would avoid that.
- **Both flavours download.** Integrators of `HyBid` also download the Smaato zips, about 12 MB each. If that matters, ship `HyBid-Smaato` as a separate package.
- **Don't link both products in one app.** Both frameworks define the same ObjC classes, and SPM can't mark products as mutually exclusive.
- **Smaato is only partly verified.** It was tested with a stand-in framework. Confirm that the real `Smaato_HyBid.xcframework` uses the module name `Smaato_HyBid` and links `OMSDK_Smaato`.
- **The vendored OMSDK xcframeworks are unsigned**, so Xcode will warn integrators about OMSDK unless IAB ships signed copies or Verve uses `--sign-omsdk`.
- **Cross-compiler compatibility is untested.** Consumers were built with the same Xcode that built the framework, so the `.swiftinterface` route used by other Xcode versions wasn't exercised. Test a release artifact with a different Xcode.
- **Release zips must be public.** They have to be downloadable without authentication; private release assets would need a `.netrc` on every integrator's machine.
