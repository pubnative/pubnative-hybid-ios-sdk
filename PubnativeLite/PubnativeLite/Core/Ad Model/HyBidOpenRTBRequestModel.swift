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

typealias DictionaryWithAnyValues = [String : Any?]

@objc public class HyBidOpenRTBRequestModel: NSObject {
    
    @objc private var adRequestModel: PNLiteAdRequestModel
    @objc private var openRTBAdType: HyBidOpenRTBAdType
    private let uuidString = NSUUID().uuidString
    
    @objc public init(adRequestModel: PNLiteAdRequestModel, openRTBAdType: HyBidOpenRTBAdType) {
        self.adRequestModel = adRequestModel
        self.openRTBAdType = openRTBAdType
    }
    
    @objc public func getOpenRTBRequestBody() -> Dictionary<String, Any> {
        let uuid = uuidString
        let app = DictionaryWithAnyValues()
        let device = HyBidOpenRTBRequestDeviceModel(adRequestModel: self.adRequestModel).getDeviceRequestBody()
        let imp = getImpObjectFor(adType: self.openRTBAdType, adRequestModel: self.adRequestModel)
        let instl = Int(adRequestModel.requestParameters[HyBidRequestParameter.interstitial()] as? String ?? "")
        let clickbrowser = Int(adRequestModel.requestParameters[HyBidRequestParameter.clickbrowser()] as? String ?? "")
        let openRTBRequestBody = [
            HyBidRequestParameter.uuid(): uuid,
            HyBidRequestParameter.interstitial(): instl,
            HyBidRequestParameter.clickbrowser(): clickbrowser,
            HyBidRequestParameter.app(): app,
            HyBidRequestParameter.device(): device,
            HyBidRequestParameter.imp(): imp,
        ] as DictionaryWithAnyValues
        
        return openRTBRequestBody as Dictionary
    }
    
    private func getImpValue(adType: HyBidOpenRTBAdType, adRequestModel: PNLiteAdRequestModel) -> [DictionaryWithAnyValues]{
        return getImpObjectFor(adType: adType, adRequestModel: adRequestModel)
    }
    
    private func getImpObjectFor(adType: HyBidOpenRTBAdType, adRequestModel: PNLiteAdRequestModel) -> [DictionaryWithAnyValues] {
        
        let width = Int(adRequestModel.requestParameters[HyBidRequestParameter.width()] as? String ?? "")
        let height = Int(adRequestModel.requestParameters[HyBidRequestParameter.height()] as? String ?? "")
        
        switch adType {
        case HyBidOpenRTBAdNative:
            let arr : [DictionaryWithAnyValues] = [
                [
                    "id": uuidString,
                    "banner": [
                        "w": width,
                        "h": height
                    ],
                    "native":
                        [
                            "request": "{\"native\":{\"ver\":\"1\",\"layout\":6,\"assets\":[{\"id\":0,\"required\":0,\"title\":{\"len\":100}},{\"id\":2,\"required\":1,\"img\":{\"type\":1,\"wmin\":50,\"hmin\":50}},{\"id\":3,\"required\":0,\"data\":{\"type\":2,\"len\":90}},{\"id\":4,\"required\":0,\"data\":{\"type\":3}},{\"id\":5,\" required\":0,\"data\":{\"type\":12,\"len\":15}},{\"id\":1,\"required\":0,\"img\":{\"type\":3,\"wmin\":300,\"hmin\":250}}]}}"
                        ]
                ]
            ]
            return self.appendSkAdNetworkParametersTo(array: arr)
        case HyBidOpenRTBAdVideo:
            let arr: [DictionaryWithAnyValues] = [
                [
                    "id": uuidString,
                    "video": getVideoRequestBody(),
                    "banner": getBannerRequestBody()
                ]
            ]
            return self.appendSkAdNetworkParametersTo(array: arr)
        case HyBidOpenRTBAdBanner:
            let arr = [
                [
                    "id": uuidString,
                    "banner": getBannerRequestBody()
                ] as DictionaryWithAnyValues
            ];
            return self.appendSkAdNetworkParametersTo(array: arr)
        default:
            return [DictionaryWithAnyValues]();
        }
    }
    
    private func getBannerRequestBody() -> DictionaryWithAnyValues {
        let requestBody: DictionaryWithAnyValues = [
            HyBidRequestParameter.screenWidthInPixels(): Int(adRequestModel.requestParameters[HyBidRequestParameter.width()] as? String ?? ""),
            HyBidRequestParameter.screenHeightInPixels(): Int(adRequestModel.requestParameters[HyBidRequestParameter.height()] as? String ?? ""),
            HyBidRequestParameter.api(): intArray(from: (adRequestModel.requestParameters[HyBidRequestParameter.api()] as? String) ?? ""),
            HyBidRequestParameter.expandDirection(): intArray(from: (adRequestModel.requestParameters[HyBidRequestParameter.expandDirection()] as? String) ?? ""),
            HyBidRequestParameter.btype(): intArray(from: (adRequestModel.requestParameters[HyBidRequestParameter.placementSubtype()] as? String) ?? ""),
            HyBidRequestParameter.topframe(): Int(adRequestModel.requestParameters[HyBidRequestParameter.topframe()] as? String ?? ""),
            HyBidRequestParameter.pos(): Int(adRequestModel.requestParameters[HyBidRequestParameter.pos()] as? String ?? ""),
            HyBidRequestParameter.mimes(): [adRequestModel.requestParameters[HyBidRequestParameter.mimes()]],
        ]
        return requestBody
    }
    
    private func getVideoRequestBody() -> DictionaryWithAnyValues {
        let requestBody: DictionaryWithAnyValues = [
            HyBidRequestParameter.videomimes(): [adRequestModel.requestParameters[HyBidRequestParameter.videomimes()]],
            HyBidRequestParameter.protocol(): intArray(from: (adRequestModel.requestParameters[HyBidRequestParameter.protocol()] as? String) ?? ""),
            HyBidRequestParameter.placementSubtype(): adRequestModel.requestParameters[HyBidRequestParameter.placementSubtype()],
            HyBidRequestParameter.videoPosition(): Int(adRequestModel.requestParameters[HyBidRequestParameter.videoPosition()] as? String ?? ""),
            HyBidRequestParameter.mraidendcard(): adRequestModel.requestParameters[HyBidRequestParameter.mraidendcard()],
            HyBidRequestParameter.playbackmethod(): intArray(from: (adRequestModel.requestParameters[HyBidRequestParameter.playbackmethod()] as? String) ?? ""),
            HyBidRequestParameter.delivery(): intArray(from: (adRequestModel.requestParameters[HyBidRequestParameter.delivery()] as? String) ?? ""),
            HyBidRequestParameter.linearity(): Int(adRequestModel.requestParameters[HyBidRequestParameter.linearity()] as? String ?? ""),
            HyBidRequestParameter.placement(): Int(adRequestModel.requestParameters[HyBidRequestParameter.placement()] as? String ?? ""),
            HyBidRequestParameter.boxingallowed(): Int(adRequestModel.requestParameters[HyBidRequestParameter.boxingallowed()] as? String ?? ""),
            HyBidRequestParameter.clickType(): Int(adRequestModel.requestParameters[HyBidRequestParameter.clickType()] as? String ?? ""),
            HyBidRequestParameter.playbackend(): Int(adRequestModel.requestParameters[HyBidRequestParameter.playbackend()] as? String ?? ""),
        ]
        return requestBody
    }
    
    private func appendSkAdNetworkParametersTo(array: Array<Any> ) -> [DictionaryWithAnyValues]{
        let model = HyBidSkAdNetworkRequestModel()
        var appID = "0"
        if ((model.getAppID() != nil) && !model.getAppID().isEmpty) {
            appID = model.getAppID()
        }
        let extDict: DictionaryWithAnyValues = [
            "ext" : [
                HyBidSKAdNetworkParameter.skadn(): [
                    HyBidSKAdNetworkParameter.sourceapp(): appID,
                    HyBidSKAdNetworkParameter.version(): model.getSkAdNetworkVersion() ?? nil,
                    "skadnetids": model.getSkAdNetworkAdNetworkIDsArray()
                ] as DictionaryWithAnyValues
            ]
        ]
        var dict: DictionaryWithAnyValues = array.first as? DictionaryWithAnyValues ?? DictionaryWithAnyValues()
        dict = dict.merging(extDict) { (_, new) in new }
        return [dict]
    }
    
    func intArray(from commaSeparatedString: String) -> [Int] {
        return commaSeparatedString.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }
}
