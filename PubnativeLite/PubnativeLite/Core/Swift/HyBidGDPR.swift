// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidGDPR: NSObject {
    
    @objc(HyBidGDPRk)
    public enum HyBidGDPRKeys: Int,CaseIterable {
        case CCPAPrivacyKey
        case GDPRConsentKey
        case GDPRAppliesKey
        case CCPAPublicPrivacyKey
        case GDPRPublicConsentKey
        case GDPRPublicConsentV2Key
        case GPPPublicString
        case GPPPublicID
        case GPPString
        case GPPID
        
        func stringValue() -> String {
            switch self {
            case .CCPAPrivacyKey: return "CCPA_Privacy"
            case .GDPRConsentKey: return "GDPR_Consent"
            case .GDPRAppliesKey: return "IABTCF_gdprApplies"
            case .CCPAPublicPrivacyKey: return "IABUSPrivacy_String"
            case .GDPRPublicConsentKey: return "IABConsent_ConsentString"
            case .GDPRPublicConsentV2Key: return "IABTCF_TCString"
            case .GPPPublicString: return "IABGPP_HDR_GppString"
            case .GPPPublicID: return "IABGPP_GppSID"
            case .GPPString: return "gpp_string"
            case .GPPID: return "gpp_id"
            }
        }
    }
    
    @available(*, unavailable)
    public override init() {
        super .init()
    }
    
    @objc(stringValueForKey:) public static func stringValue(key: HyBidGDPRKeys) -> String {
        return key.stringValue()
    }
    
    @objc public static func allGDPRKeys() -> [String] {
        return HyBidGDPRKeys.allCases.map { $0.stringValue() }
    }
}
