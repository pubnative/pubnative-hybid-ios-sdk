//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

import XCTest
@testable import HyBid

final class HyBidUserDataManagerTests: XCTestCase {

    private var manager: HyBidUserDataManager!

    private func gdprKey(_ key: HyBidGDPR.HyBidGDPRKeys) -> String {
        return key.stringValue()
    }

    private func clearUserDefaults(keys: [String]) {
        let defaults = UserDefaults.standard
        keys.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
    }

    private func relevantKeys() -> [String] {
        // Public + private keys used by HyBidUserDataManager
        let keys: [String] = [
            gdprKey(.CCPAPrivacyKey),
            gdprKey(.GDPRConsentKey),
            gdprKey(.GDPRAppliesKey),
            gdprKey(.CCPAPublicPrivacyKey),
            gdprKey(.GDPRPublicConsentKey),
            gdprKey(.GDPRPublicConsentV2Key),
            gdprKey(.GPPPublicString),
            gdprKey(.GPPPublicID),
            gdprKey(.GPPString),
            gdprKey(.GPPID),
            // Internal consent state keys (string constants in ObjC)
            "gdpr_consent_state",
            "gdpr_advertising_id"
        ]
        return Array(Set(keys))
    }

    override func setUp() {
        super.setUp()
        clearUserDefaults(keys: relevantKeys())

        manager = HyBidUserDataManager.sharedInstance()
    }

    override func tearDown() {
        clearUserDefaults(keys: relevantKeys())
        manager = nil
        super.tearDown()
    }

    // MARK: - Basic sanity

    func test_sharedInstance_isSingleton() {
        let a = HyBidUserDataManager.sharedInstance()
        let b = HyBidUserDataManager.sharedInstance()
        XCTAssertTrue(a === b)
    }

    // MARK: - GDPR applies parsing

    func test_gdprApplies_parsesStringAndNumber_viaCanCollectData() {
        let defaults = UserDefaults.standard
        let appliesKey = gdprKey(.GDPRAppliesKey)

        // Ensure consent state is not set (so GDPRConsentAsked is false).
        defaults.removeObject(forKey: "gdpr_consent_state")
        defaults.removeObject(forKey: "gdpr_advertising_id")

        // When GDPR applies and consent was not asked -> cannot collect data.
        defaults.set("1", forKey: appliesKey)
        XCTAssertFalse(manager.canCollectData())

        // When GDPR does not apply -> can collect data.
        defaults.set(0, forKey: appliesKey)
        XCTAssertTrue(manager.canCollectData())

        // NSNumber 1 should be treated as applies.
        defaults.set(NSNumber(value: 1), forKey: appliesKey)
        XCTAssertFalse(manager.canCollectData())

        // Missing value defaults to not applying.
        defaults.removeObject(forKey: appliesKey)
        XCTAssertTrue(manager.canCollectData())
    }

    func test_canCollectData_whenGDPRDoesNotApply_returnsTrue() {
        let defaults = UserDefaults.standard
        defaults.set("0", forKey: gdprKey(.GDPRAppliesKey))
        XCTAssertTrue(manager.canCollectData())
    }

    // MARK: - GDPR consent string behavior

    func test_getIABGDPRConsentString_fallsBackToPublicKeys() {
        let defaults = UserDefaults.standard
        let v2Key = gdprKey(.GDPRPublicConsentV2Key)
        let v1Key = gdprKey(.GDPRPublicConsentKey)

        defaults.set("V2CONSENT", forKey: v2Key)
        XCTAssertEqual(manager.getIABGDPRConsentString(), "V2CONSENT")

        defaults.removeObject(forKey: v2Key)
        defaults.set("V1CONSENT", forKey: v1Key)
        XCTAssertEqual(manager.getIABGDPRConsentString(), "V1CONSENT")
    }

    func test_setIABGDPRConsentString_writesToPrivateKey() {
        let privateKey = gdprKey(.GDPRConsentKey)
        manager.setIABGDPRConsentString("CONSENT-PRIVATE")

        XCTAssertEqual(UserDefaults.standard.string(forKey: privateKey), "CONSENT-PRIVATE")
    }

    // MARK: - CCPA / US privacy

    func test_getIABUSPrivacyString_fallsBackToPublicKey() {
        let defaults = UserDefaults.standard
        let publicKey = gdprKey(.CCPAPublicPrivacyKey)
        let privateKey = gdprKey(.CCPAPrivacyKey)

        defaults.removeObject(forKey: privateKey)
        defaults.set("1YYN", forKey: publicKey)

        XCTAssertEqual(manager.getIABUSPrivacyString(), "1YYN")
    }

    func test_isCCPAOptOut_trueWhenThirdCharIsY() {
        manager.setIABUSPrivacyString("1YYN") // third char = 'Y'
        XCTAssertTrue(manager.isCCPAOptOut())

        manager.setIABUSPrivacyString("1NNN")
        XCTAssertFalse(manager.isCCPAOptOut())

        manager.setIABUSPrivacyString("12") // too short
        XCTAssertFalse(manager.isCCPAOptOut())
    }

    func test_setPublicGPPString_copiesToInternalViaObserver() {
        let defaults = UserDefaults.standard
        let publicStringKey = gdprKey(.GPPPublicString)
        let internalStringKey = gdprKey(.GPPString)

        defaults.set("GPP_PUBLIC", forKey: publicStringKey)

        // NSUserDefaults KVO notifications are delivered synchronously on the same thread.
        XCTAssertEqual(defaults.string(forKey: internalStringKey), "GPP_PUBLIC")
        XCTAssertEqual(manager.getInternalGPPString(), "GPP_PUBLIC")
    }

    func test_setPublicGPPSID_copiesToInternalViaObserver() {
        let defaults = UserDefaults.standard
        let publicIdKey = gdprKey(.GPPPublicID)
        let internalIdKey = gdprKey(.GPPID)

        defaults.set("7", forKey: publicIdKey)

        // NSUserDefaults KVO notifications are delivered synchronously on the same thread.
        XCTAssertEqual(defaults.string(forKey: internalIdKey), "7")
        XCTAssertEqual(manager.getInternalGPPSID(), "7")
    }

    func test_removeGPPData_removesPublicAndInternal() {
        manager.setPublicGPPString("PUB")
        manager.setPublicGPPSID("1")
        manager.setInternalGPPString("INT")
        manager.setInternalGPPSID("2")

        manager.removeGPPInternalData()
        XCTAssertNil(manager.getInternalGPPString())
        XCTAssertNil(manager.getInternalGPPSID())

        manager.removeGPPData()
        XCTAssertNil(manager.getPublicGPPString())
        XCTAssertNil(manager.getPublicGPPSID())
    }

    // MARK: - LGPD flag

    func test_hasLGPD_canBeToggled() {
        manager.setHasLGPD(false)
        XCTAssertFalse(manager.hasLGPD())

        manager.setHasLGPD(true)
        XCTAssertTrue(manager.hasLGPD())
    }

    // MARK: - setIABGDPRConsentStringFromPublicKey coverage

    func test_init_copiesGDPRConsent_fromPublicV2_toPrivate() {
        let defaults = UserDefaults.standard
        let privateKey = gdprKey(.GDPRConsentKey)
        let v2Key = gdprKey(.GDPRPublicConsentV2Key)
        let v1Key = gdprKey(.GDPRPublicConsentKey)

        // Arrange: set both, v2 should win.
        defaults.set("V1CONSENT", forKey: v1Key)
        defaults.set("V2CONSENT", forKey: v2Key)
        defaults.removeObject(forKey: privateKey)

        var fresh: HyBidUserDataManager? = HyBidUserDataManager()

        // Assert: private key got copied from v2.
        XCTAssertEqual(defaults.string(forKey: privateKey), "V2CONSENT")
        XCTAssertEqual(fresh?.getIABGDPRConsentString(), "V2CONSENT")

        fresh = nil
    }

    func test_init_copiesGDPRConsent_fromPublicV1_toPrivate_whenV2MissingOrEmpty() {
        let defaults = UserDefaults.standard
        let privateKey = gdprKey(.GDPRConsentKey)
        let v2Key = gdprKey(.GDPRPublicConsentV2Key)
        let v1Key = gdprKey(.GDPRPublicConsentKey)

        // Arrange: v2 missing/empty, v1 present.
        defaults.removeObject(forKey: v2Key)
        defaults.set("V1CONSENT", forKey: v1Key)
        defaults.removeObject(forKey: privateKey)

        var fresh: HyBidUserDataManager? = HyBidUserDataManager()

        XCTAssertEqual(defaults.string(forKey: privateKey), "V1CONSENT")
        XCTAssertEqual(fresh?.getIABGDPRConsentString(), "V1CONSENT")

        fresh = nil
    }
}
