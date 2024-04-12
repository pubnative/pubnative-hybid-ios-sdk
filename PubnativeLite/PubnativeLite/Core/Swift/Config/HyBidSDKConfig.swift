//
//  Copyright © 2022 PubNative. All rights reserved.
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
import AppTrackingTransparency

@objc
public class HyBidSDKConfig: NSObject {
    @objc public static let sharedConfig = HyBidSDKConfig()
    
    private override init() {}
    
    @objc public var test: Bool = false
    @objc public var reporting: Bool = false
    @objc public var targeting: HyBidTargetingModel?
    @objc public var appToken: String?
    @objc public var apiURL: String {
        get {
            if #available(iOS 14, *) {
                if(ATTrackingManager.trackingAuthorizationStatus == .authorized){
                    return "https://server.pubnative.net"
                } else {
                    return "https://api.pubnative.net"
                }
            } else {
                return "https://api.pubnative.net"
            }
        }
        set {
        }
    }
    @objc public var openRtbApiURL: String = "https://dsp.pubnative.net"
    @objc public var appID: String?
}
