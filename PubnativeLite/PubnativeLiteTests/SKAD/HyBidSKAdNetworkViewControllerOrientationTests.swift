//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
import StoreKit
import UIKit
@testable import HyBid

/// Regression tests for the orientation crash fixed in VMI-1553 / VMI-1607 / VMI-1605.
///
/// The crash was caused by HyBid's extension on SKStoreProductViewController overriding
/// supportedInterfaceOrientations and delegating to presentingViewController, which in turn
/// asked its visibleViewController — creating infinite recursion under iOS's orientation
/// query lock. Removing the override eliminates the cycle; these tests confirm it stays gone.
@MainActor
final class HyBidSKAdNetworkViewControllerOrientationTests: XCTestCase {

    // MARK: - Recursive-cycle regression (VMI-1553 / VMI-1607 / VMI-1605)

    /// Reproduces the exact runtime topology that caused the crash:
    /// skVC.presentingViewController == navVC, navVC.visibleViewController == skVC.
    /// If HyBid ever reintroduces an orientation override that delegates to presentingViewController,
    /// this test will crash with a stack overflow.
    func test_supportedInterfaceOrientations_withRecursivePresentingVC_doesNotCrash() {
        let skVC = MockSKStoreProductViewController()
        let navVC = RecursiveOrientationNavController(rootViewController: UIViewController())
        skVC.mockPresentingViewController = navVC
        navVC.mockVisibleVC = skVC

        XCTAssertNoThrow({ _ = skVC.supportedInterfaceOrientations }())
        XCTAssertNotEqual(skVC.supportedInterfaceOrientations.rawValue, 0)
    }

    func test_shouldAutorotate_withRecursivePresentingVC_doesNotCrash() {
        let skVC = MockSKStoreProductViewController()
        let navVC = RecursiveOrientationNavController(rootViewController: UIViewController())
        skVC.mockPresentingViewController = navVC
        navVC.mockVisibleVC = skVC

        XCTAssertNoThrow({ _ = skVC.shouldAutorotate }())
    }

    // MARK: - Baseline sanity checks

    func test_supportedInterfaceOrientations_doesNotCrash() {
        let skVC = SKStoreProductViewController()
        XCTAssertNoThrow({ _ = skVC.supportedInterfaceOrientations }())
    }

    func test_supportedInterfaceOrientations_returnsNonZeroMask() {
        let skVC = SKStoreProductViewController()
        XCTAssertNotEqual(skVC.supportedInterfaceOrientations.rawValue, 0)
    }

    func test_supportedInterfaceOrientations_calledRepeatedly_returnsSameValue() {
        let skVC = SKStoreProductViewController()
        let first  = skVC.supportedInterfaceOrientations
        let second = skVC.supportedInterfaceOrientations
        let third  = skVC.supportedInterfaceOrientations
        XCTAssertEqual(first, second)
        XCTAssertEqual(second, third)
    }

    func test_shouldAutorotate_doesNotCrash() {
        let skVC = SKStoreProductViewController()
        XCTAssertNoThrow({ _ = skVC.shouldAutorotate }())
    }
}

@MainActor
final class HyBidSKAdNetworkViewControllerStoreKitParameterTests: XCTestCase {

    func test_aakStoreKitLoad_withProductionBridgedRealWorldSKAdNetwork4Parameters_usesAAK() throws {
        guard #available(iOS 14.5, *) else { return }
        let ad = try makeProductionAd()
        let model = try XCTUnwrap(ad.getSkAdNetworkModel())
        let fidelities = try XCTUnwrap(model.productParameters?["fidelities"] as? [NSDictionary])
        let impression = try XCTUnwrap(HyBidAdImpression.sharedInstance().generateSkAdImpression(from: model))
        let parameters = NSMutableDictionary(dictionary: model.getStoreKitParameters())
        HyBidStoreKitUtils.insertFidelities(intoDictionaryIfNeeded: parameters)
        let bridgedParameters = try XCTUnwrap(parameters as? [String: Any])

        XCTAssertEqual(fidelities.count, 2)
        XCTAssertEqual(impression.timestamp, 1_746_439_962_277)
        XCTAssertEqual(impression.adImpressionIdentifier, "5626d1c8-6a1e-a5a7-2dd4-dbafe5e84e7a")
        XCTAssertEqual(impression.signature, "MDYCGQChayMNa14sQlWbBTny369LwifOR2edlnECGQCznqVt2COMaTbyepBE3EtjZDYonBOLR7s=")
        XCTAssertTrue(HyBidSKAdNetworkViewController.canLoadStoreKitProductWithAAK(parameters: bridgedParameters))
        XCTAssertEqual(parameters[SKStoreProductParameterAdNetworkTimestamp] as? NSNumber, 1_746_439_962_421)
        XCTAssertEqual(parameters[SKStoreProductParameterAdNetworkNonce] as? NSUUID, NSUUID(uuidString: "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea"))
        XCTAssertEqual(parameters[SKStoreProductParameterAdNetworkAttributionSignature] as? String, "MDYCGQChayMNa14sQlWbBTny369LwifOR2edlnECGQCznqVt2COMaTbyepBE3EtjZDYonBOLR7s=")
    }

    func test_aakStoreKitLoad_withVMI1697PayloadWithoutStoreKitFidelity_preservesJSONSafeFidelities() throws {
        guard #available(iOS 14.5, *) else { return }
        let ad = try makeProductionAd(withoutStoreKitFidelity: true)
        let model = try XCTUnwrap(ad.getSkAdNetworkModel())
        let parameters = NSMutableDictionary(dictionary: model.getStoreKitParameters())

        HyBidStoreKitUtils.insertFidelities(intoDictionaryIfNeeded: parameters)

        let fidelities = try XCTUnwrap(parameters["fidelities"] as? [NSDictionary])
        let fidelity = try XCTUnwrap(fidelities.first)
        let bridgedParameters = try XCTUnwrap(parameters as? [String: Any])
        let objectiveCParameters = try XCTUnwrap(parameters as? [AnyHashable: Any])
        let cleanedParameters = try XCTUnwrap(HyBidStoreKitUtils.cleanUpProductParams(objectiveCParameters))
        XCTAssertEqual(fidelities.count, 1)
        XCTAssertEqual(fidelity["fidelity"] as? NSNumber, 0)
        XCTAssertTrue(HyBidSKAdNetworkViewController.canLoadStoreKitProductWithAAK(parameters: bridgedParameters))
        XCTAssertNil(cleanedParameters["fidelities"])
    }

    func test_skanModel_withMalformedFidelityValues_dropsInvalidEntriesWithoutCrashingConsumers() throws {
        let malformedValues: [(String, Any)] = [
            ("signature", 1),
            ("nonce", NSNull()),
            ("timestamp", 1),
            ("fidelity", "1")
        ]

        for (key, value) in malformedValues {
            let ad = try makeProductionAd(mutateStoreKitFidelity: { $0[key] = value })
            let model = try XCTUnwrap(ad.getSkAdNetworkModel())
            let fidelities = try XCTUnwrap(model.productParameters?["fidelities"] as? [NSDictionary])
            let parameters = NSMutableDictionary(dictionary: model.getStoreKitParameters())

            XCTAssertEqual(fidelities.count, 1)
            XCTAssertEqual(fidelities.first?["fidelity"] as? NSNumber, 0)
            XCTAssertTrue(model.checkV2_2_Parameters(model.productParameters, supportMultipleFidelities: true))
            XCTAssertNoThrow(HyBidStoreKitUtils.insertFidelities(intoDictionaryIfNeeded: parameters))
        }
    }

    func test_skanModelValidation_withNonStringFidelityValue_returnsFalse() throws {
        let model = try XCTUnwrap(makeProductionAd().getSkAdNetworkModel())
        let fidelity: [String: Any] = [
            "signature": 1,
            "nonce": "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea",
            "timestamp": "1746439962421"
        ]

        XCTAssertFalse(model.checkV2_2_Parameters(["fidelities": [fidelity]], supportMultipleFidelities: true))
    }

    func test_skanModelValidation_withNonArrayFidelities_returnsFalse() throws {
        let model = try XCTUnwrap(makeProductionAd().getSkAdNetworkModel())

        XCTAssertFalse(model.checkV2_2_Parameters(["fidelities": NSNull()], supportMultipleFidelities: true))
    }

    func test_adImpression_withMalformedFidelityContainers_ignoresThem() throws {
        guard #available(iOS 14.5, *) else { return }
        let model = try XCTUnwrap(makeProductionAd().getSkAdNetworkModel())
        let malformedFidelities: [Any] = [NSNull(), [NSNull()]]

        for value in malformedFidelities {
            var parameters = try XCTUnwrap(model.productParameters)
            parameters["fidelities"] = value
            model.productParameters = parameters

            XCTAssertNoThrow(HyBidAdImpression.sharedInstance().generateSkAdImpression(from: model))
        }
    }

    func test_adImpression_withMalformedFidelityFields_skipsThem() throws {
        guard #available(iOS 14.5, *) else { return }
        let model = try XCTUnwrap(makeProductionAd().getSkAdNetworkModel())
        let validFidelity: [String: Any] = [
            "fidelity": 0,
            "timestamp": "1746439962277",
            "nonce": "5626d1c8-6a1e-a5a7-2dd4-dbafe5e84e7a",
            "signature": "signature"
        ]
        let malformedValues: [(String, Any)] = [
            ("fidelity", NSNull()),
            ("fidelity", "0"),
            ("timestamp", NSNull()),
            ("timestamp", 1),
            ("timestamp", "invalid"),
            ("nonce", NSNull()),
            ("nonce", ""),
            ("signature", NSNull()),
            ("signature", 1)
        ]
        var fidelities: [[String: Any]] = malformedValues.map { key, value in
            var fidelity = validFidelity
            fidelity[key] = value
            return fidelity
        }
        var missingFieldFidelity = validFidelity
        missingFieldFidelity.removeValue(forKey: "signature")
        fidelities.append(missingFieldFidelity)
        fidelities.append(validFidelity)
        var parameters = try XCTUnwrap(model.productParameters)
        parameters["fidelities"] = fidelities
        model.productParameters = parameters

        let impression = try XCTUnwrap(HyBidAdImpression.sharedInstance().generateSkAdImpression(from: model))

        XCTAssertEqual(impression.timestamp, 1_746_439_962_277)
        XCTAssertEqual(impression.adImpressionIdentifier, "5626d1c8-6a1e-a5a7-2dd4-dbafe5e84e7a")
        XCTAssertEqual(impression.signature, "signature")
    }

    func test_storeKitUtils_withMalformedFidelities_skipsThemAndPromotesValidFidelity() throws {
        guard #available(iOS 14.0, *) else { return }
        let binary = try XCTUnwrap(NSData(base64Encoded: "AQ==", options: []))
        for unsupportedFidelities: Any in [NSNull(), binary] {
            let parameters = NSMutableDictionary(dictionary: [
                SKStoreProductParameterAdNetworkVersion: "4.0",
                "fidelities": unsupportedFidelities
            ])

            XCTAssertNoThrow(HyBidStoreKitUtils.insertFidelities(intoDictionaryIfNeeded: parameters))
        }

        let validFidelity: [String: Any] = [
            "fidelity": 1,
            "timestamp": "1746439962421",
            "nonce": "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea",
            "signature": "signature"
        ]
        let malformedFidelities: [Any] = [
            NSNull(),
            binary,
            ["fidelity": NSNull(), "timestamp": "1746439962421", "nonce": "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea", "signature": "signature"],
            ["fidelity": 1, "timestamp": 1, "nonce": "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea", "signature": "signature"],
            ["fidelity": 1, "timestamp": "1746439962421", "nonce": binary, "signature": "signature"],
            ["fidelity": 1, "timestamp": "1746439962421", "nonce": "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea", "signature": NSNull()],
            validFidelity
        ]
        let parameters = NSMutableDictionary(dictionary: [
            SKStoreProductParameterAdNetworkVersion: "4.0",
            "fidelities": malformedFidelities
        ])

        HyBidStoreKitUtils.insertFidelities(intoDictionaryIfNeeded: parameters)

        XCTAssertNil(parameters["fidelities"])
        XCTAssertEqual(parameters[SKStoreProductParameterAdNetworkTimestamp] as? NSNumber, 1_746_439_962_421)
        XCTAssertEqual(parameters[SKStoreProductParameterAdNetworkNonce] as? NSUUID, NSUUID(uuidString: "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea"))
        XCTAssertEqual(parameters[SKStoreProductParameterAdNetworkAttributionSignature] as? String, "signature")
    }

    func test_openRTBSKANModel_withNonDictionaryFidelity_preservesValidFidelities() throws {
        let ad = try makeProductionAd(useOpenRTBSKAdNetworkModel: true, mutateFidelities: { fidelities in
            fidelities.insert(NSNull(), at: 0)
        })
        let model = try XCTUnwrap(ad.getOpenRTBSkAdNetworkModel())
        let fidelities = try XCTUnwrap(model.productParameters?["fidelities"] as? [NSDictionary])

        XCTAssertEqual(fidelities.count, 2)
    }

    func test_skanModels_withNonArrayFidelities_ignoreThem() throws {
        for useOpenRTB in [false, true] {
            for value: Any in [NSNull(), "invalid"] {
                let ad = try makeProductionAd(useOpenRTBSKAdNetworkModel: useOpenRTB, replaceFidelitiesWith: value)
                let model = useOpenRTB ? ad.getOpenRTBSkAdNetworkModel() : ad.getSkAdNetworkModel()

                XCTAssertNil(model?.productParameters?["fidelities"])
            }
        }
    }

    func test_aakStoreKitLoad_withObjectiveCInlineData_usesLegacyFallback() throws {
        let parameters = NSMutableDictionary(dictionary: makeRealWorldSKAdNetwork4Parameters())
        let fidelity = try XCTUnwrap(NSData(base64Encoded: "AQ==", options: []))
        parameters["fidelities"] = NSMutableArray(object: fidelity)
        let bridgedParameters = try XCTUnwrap(parameters as? [String: Any])

        XCTAssertFalse(HyBidSKAdNetworkViewController.canLoadStoreKitProductWithAAK(parameters: bridgedParameters))
    }

    private func makeRealWorldSKAdNetwork4Parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            SKStoreProductParameterITunesItemIdentifier: 1_506_188_465,
            SKStoreProductParameterAdNetworkIdentifier: "m2jqnlggk3.adattributionkit",
            SKStoreProductParameterAdNetworkNonce: NSUUID(uuidString: "d704f93f-f9c7-617d-a6a5-f43fc1bbdbea")!,
            SKStoreProductParameterAdNetworkTimestamp: 1_746_439_962_421,
            SKStoreProductParameterAdNetworkAttributionSignature: "MDYCGQChayMNa14sQlWbBTny369LwifOR2edlnECGQCznqVt2COMaTbyepBE3EtjZDYonBOLR7s="
        ]
        if #available(iOS 14.0, *) {
            parameters[SKStoreProductParameterAdNetworkVersion] = "4.0"
            parameters[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] = 0
        }
        if #available(iOS 16.1, *) {
            parameters[SKStoreProductParameterAdNetworkSourceIdentifier] = 82
        }
        return parameters
    }

    private func makeProductionAd(
        withoutStoreKitFidelity: Bool = false,
        useOpenRTBSKAdNetworkModel: Bool = false,
        mutateFidelities: ((NSMutableArray) -> Void)? = nil,
        replaceFidelitiesWith: Any? = nil,
        mutateStoreKitFidelity: ((NSMutableDictionary) -> Void)? = nil
    ) throws -> HyBidAd {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "AdResponse", withExtension: "json"))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url), options: .mutableContainers) as? NSMutableDictionary)
        if withoutStoreKitFidelity || useOpenRTBSKAdNetworkModel || mutateFidelities != nil || replaceFidelitiesWith != nil || mutateStoreKitFidelity != nil {
            let ads = try XCTUnwrap(json["ads"] as? NSMutableArray)
            let ad = try XCTUnwrap(ads.firstObject as? NSMutableDictionary)
            let meta = try XCTUnwrap(ad["meta"] as? NSMutableArray)
            let skAdNetwork = try XCTUnwrap(meta.first { ($0 as? NSDictionary)?["type"] as? String == "skadnetwork" } as? NSMutableDictionary)
            let data = try XCTUnwrap(skAdNetwork["data"] as? NSMutableDictionary)
            let fidelities = try XCTUnwrap(data["fidelities"] as? NSMutableArray)
            let viewThroughFidelity = try XCTUnwrap(fidelities.first { (($0 as? NSDictionary)?["fidelity"] as? NSNumber)?.intValue == 0 })
            mutateFidelities?(fidelities)
            if withoutStoreKitFidelity {
                data["fidelities"] = NSMutableArray(object: viewThroughFidelity)
            }
            if let mutateStoreKitFidelity {
                let storeKitFidelity = try XCTUnwrap(fidelities.first { (($0 as? NSDictionary)?["fidelity"] as? NSNumber)?.intValue == 1 } as? NSMutableDictionary)
                mutateStoreKitFidelity(storeKitFidelity)
            }
            if let replaceFidelitiesWith {
                data["fidelities"] = replaceFidelitiesWith
            }
            if useOpenRTBSKAdNetworkModel {
                let remoteConfigs = try XCTUnwrap(meta.first { ($0 as? NSDictionary)?["type"] as? String == "remoteconfigs" } as? NSMutableDictionary)
                let remoteConfigData = try XCTUnwrap(remoteConfigs["data"] as? NSMutableDictionary)
                let jsonData = try XCTUnwrap(remoteConfigData["jsondata"] as? NSMutableDictionary)
                jsonData["skadnetwork_input_value"] = ["skadn": data]
            }
        }
        let responseDictionary = try XCTUnwrap(json as? [AnyHashable: Any])
        let response = try XCTUnwrap(PNLiteResponseModel(dictionary: responseDictionary))
        let adModel = try XCTUnwrap(response.ads?.first as? HyBidAdModel)
        return try XCTUnwrap(HyBidAd(data: adModel, withZoneID: "4"))
    }
}

// MARK: - Test Doubles

/// Lets tests inject a mock presentingViewController without a real window hierarchy,
/// replicating the runtime state where skVC has been modally presented over a nav controller.
private class MockSKStoreProductViewController: SKStoreProductViewController {
    var mockPresentingViewController: UIViewController?
    override var presentingViewController: UIViewController? { mockPresentingViewController }
}

/// Simulates the UINavigationController(Autorotate) category from the crash log.
/// Its supportedInterfaceOrientations queries visibleViewController, which in the crash
/// scenario pointed back to the SKStoreProductViewController — forming the recursive cycle.
private class RecursiveOrientationNavController: UINavigationController {
    var mockVisibleVC: UIViewController?

    override var visibleViewController: UIViewController? {
        mockVisibleVC ?? super.visibleViewController
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
}
