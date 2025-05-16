// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

private typealias GeolocationValues = (accuracy: Int?, utcoffset: Int?)

struct HyBidOpenRTBRequestGeolocationModel {
    private var geolocationValues = GeolocationValues(accuracy: .none, utcoffset: .none)
    
    init() {
        if HyBidLocationConfig.sharedConfig.locationTrackingEnabled, let location = HyBidSettings.sharedInstance.location {
            geolocationValues.accuracy = Int(location.horizontalAccuracy)
        }
        
        let totalOffsetSeconds = NSTimeZone.local.secondsFromGMT(for: Date())
        geolocationValues.utcoffset = Int(totalOffsetSeconds / 60)
    }
    
    func getGeolocationRequestBody() -> DictionaryWithAnyValues {
        var geolocationDictionary = DictionaryWithAnyValues()
        geolocationDictionary[HyBidRequestParameter.accuracy()] = geolocationValues.accuracy
        geolocationDictionary[HyBidRequestParameter.utcoffset()] = geolocationValues.utcoffset
        return geolocationDictionary
    }
}
