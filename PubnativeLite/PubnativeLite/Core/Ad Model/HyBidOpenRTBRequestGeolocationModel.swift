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
