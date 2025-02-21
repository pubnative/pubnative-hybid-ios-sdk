//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
