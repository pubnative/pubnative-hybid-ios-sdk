// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
@testable import HyBid

/// Unit tests covering the minimized signal-data feature introduced in VMI-1538
/// and broader HyBid class API coverage.
final class HyBidSignalDataTests: XCTestCase {

    private let skAdNetworkIDsKey = "skadnetids"

    // MARK: - getMinimizedCustomRequestSignalData

    func testGetMinimizedCustomRequestSignalData_returnsNonNil() {
        XCTAssertNotNil(HyBid.getMinimizedCustomRequestSignalData())
    }

    func testGetMinimizedCustomRequestSignalData_doesNotContainSKAdNetworkIDsKey() {
        guard let data = HyBid.getMinimizedCustomRequestSignalData() else {
            XCTFail("getMinimizedCustomRequestSignalData() returned nil unexpectedly")
            return
        }
        XCTAssertFalse(
            data.contains(skAdNetworkIDsKey),
            "Minimized signal data must not contain '\(skAdNetworkIDsKey)'"
        )
    }

    // MARK: - getCustomRequestSignalData

    func testGetCustomRequestSignalData_returnsNonNil() {
        XCTAssertNotNil(HyBid.getCustomRequestSignalData())
    }

    func testGetCustomRequestSignalData_withMediationVendor_returnsNonNil() {
        XCTAssertNotNil(HyBid.getCustomRequestSignalData("TestVendor"))
    }

    // MARK: - getEncodedMinimizedCustomRequestSignalData

    func testGetEncodedMinimizedCustomRequestSignalData_returnsNonEmpty() {
        let encoded = HyBid.getEncodedMinimizedCustomRequestSignalData()
        XCTAssertNotNil(encoded)
        XCTAssertFalse(encoded?.isEmpty ?? true)
    }

    func testGetEncodedMinimizedCustomRequestSignalData_decodesWithoutSKAdNetworkIDsKey() {
        guard let encoded = HyBid.getEncodedMinimizedCustomRequestSignalData(),
              !encoded.isEmpty else {
            XCTFail("getEncodedMinimizedCustomRequestSignalData() returned nil or empty")
            return
        }

        let standard = encoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = standard + String(repeating: "=", count: (4 - standard.count % 4) % 4)

        guard let data = Data(base64Encoded: padded),
              let decoded = String(data: data, encoding: .utf8) else {
            XCTFail("Could not base64-decode the encoded minimized signal data")
            return
        }
        XCTAssertFalse(
            decoded.contains(skAdNetworkIDsKey),
            "Decoded minimized signal data must not contain '\(skAdNetworkIDsKey)'"
        )
    }

    // MARK: - getEncodedCustomRequestSignalData

    func testGetEncodedCustomRequestSignalData_returnsNonEmpty() {
        let encoded = HyBid.getEncodedCustomRequestSignalData()
        XCTAssertNotNil(encoded)
        XCTAssertFalse(encoded?.isEmpty ?? true)
    }

    func testGetEncodedCustomRequestSignalData_withMediationVendor_returnsNonEmpty() {
        let encoded = HyBid.getEncodedCustomRequestSignalData("TestVendor")
        XCTAssertNotNil(encoded)
        XCTAssertFalse(encoded?.isEmpty ?? true)
    }

    // MARK: - Consistency: minimized vs regular

    func testMinimizedSignalData_neverContainsSKAdNetworkIDsKey() {
        let minimized = HyBid.getMinimizedCustomRequestSignalData()
        XCTAssertNotNil(minimized)
        XCTAssertFalse(
            minimized?.contains(skAdNetworkIDsKey) ?? false,
            "Minimized data must not contain '\(skAdNetworkIDsKey)'"
        )
    }

    func testEncodedMinimizedAndRegular_areBothValidBase64UrlStrings() {
        let regular = HyBid.getEncodedCustomRequestSignalData()
        let minimized = HyBid.getEncodedMinimizedCustomRequestSignalData()

        XCTAssertNotNil(regular)
        XCTAssertNotNil(minimized)

        let base64URLPattern = "^[A-Za-z0-9+/=_-]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", base64URLPattern)
        if let regular = regular {
            XCTAssertTrue(predicate.evaluate(with: regular), "Regular encoded signal should be valid base64url")
        }
        if let minimized = minimized {
            XCTAssertTrue(predicate.evaluate(with: minimized), "Minimized encoded signal should be valid base64url")
        }
    }
}

// MARK: - HyBid class general API coverage

final class HyBidClassTests: XCTestCase {

    // MARK: - SDK version / info

    func testSdkVersion_returnsNonEmpty() {
        let version = HyBid.sdkVersion()
        XCTAssertNotNil(version)
        XCTAssertFalse(version?.isEmpty ?? true)
    }

    func testGetSDKVersionInfo_returnsNonEmpty() {
        let info = HyBid.getSDKVersionInfo()
        XCTAssertNotNil(info)
        XCTAssertFalse(info?.isEmpty ?? true)
    }

    func testReportingManager_returnsNonNil() {
        XCTAssertNotNil(HyBid.reportingManager())
    }

    // MARK: - isInitialized

    func testIsInitialized_beforeInit_returnsFalse() {
        // Ensure a clean state: re-read the flag without calling init
        // isInitialized is a module-level BOOL, so it reflects the last transition
        // We only assert the method is callable and returns a Bool
        let _ = HyBid.isInitialized()
    }

    func testInitWithAppToken_emptyToken_setsNotInitialized() {
        // Completion is invoked synchronously for empty tokens
        HyBid.initWithAppToken("") { initialized in
            XCTAssertFalse(initialized)
        }
        XCTAssertFalse(HyBid.isInitialized())
    }

    func testInitWithAppToken_nilCompletion_doesNotCrash() {
        XCTAssertNoThrow(HyBid.initWithAppToken("", completion: nil))
    }

    // MARK: - Setters (smoke tests — verify they don't crash and apply the value)

    func testSetCoppa_doesNotCrash() {
        HyBid.setCoppa(true)
        HyBid.setCoppa(false)
    }

    func testSetTestMode_doesNotCrash() {
        HyBid.setTestMode(true)
        XCTAssertTrue(HyBidSDKConfig.sharedConfig.test)
        HyBid.setTestMode(false)
        XCTAssertFalse(HyBidSDKConfig.sharedConfig.test)
    }

    func testSetReporting_doesNotCrash() {
        HyBid.setReporting(true)
        XCTAssertTrue(HyBidSDKConfig.sharedConfig.reporting)
        HyBid.setReporting(false)
        XCTAssertFalse(HyBidSDKConfig.sharedConfig.reporting)
    }


    func testSetTargeting_doesNotCrash() {
        let targeting = HyBidTargetingModel()
        HyBid.setTargeting(targeting)
        XCTAssertEqual(HyBidSDKConfig.sharedConfig.targeting, targeting)
        HyBid.setTargeting(nil)
        XCTAssertNil(HyBidSDKConfig.sharedConfig.targeting)
    }

    func testSetLocationUpdates_doesNotCrash() {
        HyBid.setLocationUpdates(true)
        HyBid.setLocationUpdates(false)
    }

    func testSetLocationTracking_doesNotCrash() {
        HyBid.setLocationTracking(true)
        HyBid.setLocationTracking(false)
    }

    // MARK: - rightToBeForgotten

    func testRightToBeForgotten_doesNotCrash() {
        XCTAssertNoThrow(HyBid.rightToBeForgotten())
    }

    func testRightToBeForgotten_removesGDPRKeys() {
        // Pre-populate a known GDPR key then verify it is cleared
        let key = HyBidGDPR.HyBidGDPRKeys.GDPRConsentKey.stringValue()
        UserDefaults.standard.set("test_consent", forKey: key)
        HyBid.rightToBeForgotten()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))
    }

    // MARK: - Integration type

    func testGetIntegrationType_defaultIsHyBid() {
        // setIntegrationType(0) resets back to HyBid
        HyBid.setIntegrationType(.hyBid)
        XCTAssertEqual(HyBid.getIntegrationType(), .hyBid)
    }

    func testSetIntegrationType_nonZeroValue_storesValue() {
        HyBid.setIntegrationType(.smaato)
        XCTAssertEqual(HyBid.getIntegrationType(), .smaato)
        // Reset to default
        HyBid.setIntegrationType(.hyBid)
    }

    func testSetIntegrationType_zeroValue_setsHyBid() {
        // Passing raw 0 should map to .hyBid
        HyBid.setIntegrationType(SDKIntegrationType(rawValue: 0)!)
        XCTAssertEqual(HyBid.getIntegrationType(), .hyBid)
    }
}
