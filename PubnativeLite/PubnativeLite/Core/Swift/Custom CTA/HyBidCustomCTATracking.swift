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
public class HyBidCustomCTATracking: NSObject {
    
    private let PNLiteAdCustomCTAImpression = "custom_cta_show"
    private let PNLiteAdCustomCTAClick = "custom_cta_click"
    private let PNLiteAdCustomCTAEndCardClick = "custom_cta_endcard_click"
    
    private var impressionBeaconsArray: Array<HyBidDataModel> = []
    private var clickBeaconsArray: Array<HyBidDataModel> = []
    private var endCardClickBeaconsArray: Array<HyBidDataModel> = []
    
    @available(*, unavailable)
    public override init() {}
    
    @objc public init(ad: HyBidAd) {
        if let impressionBeacons = ad.beaconsData(withType: PNLiteAdCustomCTAImpression) as? Array<HyBidDataModel> {
            self.impressionBeaconsArray = impressionBeacons
        }
        
        if let clickBeacons = ad.beaconsData(withType: PNLiteAdCustomCTAClick) as? Array<HyBidDataModel> {
            self.clickBeaconsArray = clickBeacons
        }
        
        if let endCardClickBeacons = ad.beaconsData(withType: PNLiteAdCustomCTAEndCardClick) as? Array<HyBidDataModel> {
            self.endCardClickBeaconsArray = endCardClickBeacons
        }
    }
    
    @objc public func impressionBeacons() -> Array<HyBidDataModel> { return self.impressionBeaconsArray }
    
    @objc public func clickBeacons() -> Array<HyBidDataModel> { return self.clickBeaconsArray }
    
    @objc public func endCardClickBeacons() -> Array<HyBidDataModel> { return self.endCardClickBeaconsArray }
}
