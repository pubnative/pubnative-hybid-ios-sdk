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

#if canImport(ATOM)
    import ATOM
#endif

@objc public class ATOMManager: NSObject
{
    @objc public class func fireAdSessionEvent(data: HyBidAdSessionData) {
        var adSessionDict: [String: Any] = [:]
        
        if let creativeId = data.creativeId, !creativeId.isEmpty {
            adSessionDict["Creative_id"] = creativeId
        }
        if let campaignId = data.campaignId, !campaignId.isEmpty {
            adSessionDict["Campaign_id"] = campaignId
        }
        if let bidPrice = data.bidPrice, !bidPrice.isEmpty {
            adSessionDict["Bid_price"] = bidPrice
        }
        if let adFormat = data.adFormat, !adFormat.isEmpty {
            adSessionDict["Ad format"] = adFormat
        }
        if let renderingStatus = data.renderingStatus, !renderingStatus.isEmpty {
            adSessionDict["Rendering_status"] = renderingStatus
        }
        if let viewability = data.viewability {
            adSessionDict["Viewability"] = viewability
        }
        
        guard !adSessionDict.isEmpty else {
            return
        }
        
        let jsonObject: [String: Any] = [
            HyBidConstants.AD_SESSION_DATA: adSessionDict
        ]
        
        #if canImport(ATOM)
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            Atom.fire(eventWithName: HyBidConstants.AD_SESSION_DATA, eventWithValue: jsonString)
            ATOMManager.reportAdSessionDataSharedEvent(adSessionDict:adSessionDict)
        }
        #endif
    }
    
    @objc public class func createAdSessionData(from request: HyBidAdRequest?, ad: HyBidAd) -> HyBidAdSessionData {
        let adSessionData = HyBidAdSessionData()
        if let creativeId = ad.creativeID {
            adSessionData.creativeId = creativeId
        }

        if let campaignID = ad.campaignID {
            adSessionData.campaignId = campaignID
        }
        
        if let adFormat = request?.getAdFormat() {
            adSessionData.adFormat = adFormat
        }
        
        if (adSessionData.adFormat == nil) {
            if let adFormat = ad.adFormat {
                adSessionData.adFormat = adFormat
            }
        }

        if let bidPrice = HyBidHeaderBiddingUtils.eCPM(from: ad, withDecimalPlaces: HyBidKeywordMode.THREE_DECIMAL_PLACES) {
            adSessionData.bidPrice = bidPrice
        }

        adSessionData.viewability = 1
        adSessionData.renderingStatus = HyBidConstants.RENDERING_SUCCESS
        return adSessionData
    }
    
    @objc public class func reportAdSessionDataSharedEvent(adSessionDict: [String: Any]) {
        if HyBidSDKConfig.sharedConfig.reporting {
            let properties = [HyBidConstants.AD_SESSION_DATA: adSessionDict]
            let reportingEvent = HyBidReportingEvent(
                with: EventType.AD_SESSION_DATA_SHARED_TO_ATOM,
                adFormat: nil,
                properties: properties
            )
            HyBid.reportingManager().reportEvent(for: reportingEvent)
        }
    }
}
