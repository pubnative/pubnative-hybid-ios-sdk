// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

struct HyBidOpenRTBRequestDeviceModel {
    private let adRequestModel: PNLiteAdRequestModel
    
    init(adRequestModel: PNLiteAdRequestModel) {
        self.adRequestModel = adRequestModel
    }
    
    func getDeviceRequestBody() -> DictionaryWithAnyValues {
        guard let parameters = adRequestModel.requestParameters else { return DictionaryWithAnyValues() }
     
        var requestBody: DictionaryWithAnyValues = [
            HyBidRequestParameter.extension(): getExtensionBody(),
            HyBidRequestParameter.ip(): parameters[HyBidRequestParameter.ip()] as? String,
            HyBidRequestParameter.os(): parameters[HyBidRequestParameter.os()] as? String,
            HyBidRequestParameter.userAgent(): HyBidWebBrowserUserAgentInfo.hyBidUserAgent(),
            HyBidRequestParameter.geolocation(): HyBidOpenRTBRequestGeolocationModel().getGeolocationRequestBody(),
            HyBidRequestParameter.osVersion(): parameters[HyBidRequestParameter.osVersion()] as? String,
            HyBidRequestParameter.deviceType(): Int(parameters[HyBidRequestParameter.deviceType()] as? String ?? ""),
            HyBidRequestParameter.deviceMake(): parameters[HyBidRequestParameter.deviceMake()] as? String,
            HyBidRequestParameter.deviceModel(): parameters[HyBidRequestParameter.deviceModel()] as? String,
            HyBidRequestParameter.deviceModelIdentifier(): parameters[HyBidRequestParameter.deviceModelIdentifier()] as? String,
            HyBidRequestParameter.deviceHeight(): Int(parameters[HyBidRequestParameter.deviceHeight()] as? String ?? ""),
            HyBidRequestParameter.deviceWidth(): Int(parameters[HyBidRequestParameter.deviceWidth()] as? String ?? ""),
            HyBidRequestParameter.pxRatio(): Float(parameters[HyBidRequestParameter.pxRatio()] as? String ?? ""),
            HyBidRequestParameter.js(): Int(parameters[HyBidRequestParameter.js()] as? String ?? ""),
            HyBidRequestParameter.language(): parameters[HyBidRequestParameter.language()] as? String,
            HyBidRequestParameter.geoFetch(): Int(parameters[HyBidRequestParameter.geoFetch()] as? String ?? ""),
        ]
        
        if #available(iOS 16.0, *) {} else {
            requestBody[HyBidRequestParameter.carrier()] = parameters[HyBidRequestParameter.carrier()] as? String
            requestBody[HyBidRequestParameter.carrierMCCMNC()] = parameters[HyBidRequestParameter.carrierMCCMNC()] as? String
        }
        if #available(iOS 14.1, *) {
            requestBody[HyBidRequestParameter.connectiontype()] = Int(parameters[HyBidRequestParameter.connectiontype()] as? String ?? "")
        }
        return requestBody
    }
    
    private func getExtensionBody() -> DictionaryWithAnyValues {
        let requestBody: DictionaryWithAnyValues = [
            HyBidRequestParameter.charging(): Int(adRequestModel.requestParameters[HyBidRequestParameter.charging()] as? String ?? ""),
            HyBidRequestParameter.batteryLevel(): Int(adRequestModel.requestParameters[HyBidRequestParameter.batteryLevel()] as? String ?? ""),
            HyBidRequestParameter.batterySaver(): Int(adRequestModel.requestParameters[HyBidRequestParameter.batterySaver()] as? String ?? ""),
            HyBidRequestParameter.darkmode(): Int(adRequestModel.requestParameters[HyBidRequestParameter.darkmode()] as? String ?? ""),
            HyBidRequestParameter.appTrackingTransparency(): Int(adRequestModel.requestParameters[HyBidRequestParameter.appTrackingTransparency()] as? String ?? ""),
            HyBidRequestParameter.airplaneMode(): Int(adRequestModel.requestParameters[HyBidRequestParameter.airplaneMode()] as? String ?? ""),
        ]
        return requestBody
    }
}
