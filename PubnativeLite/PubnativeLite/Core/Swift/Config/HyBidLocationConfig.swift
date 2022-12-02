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
import CoreLocation

@objc
public class HyBidLocationConfig: NSObject {
    
    @objc public static let sharedConfig = HyBidLocationConfig()
    
    private override init() {
        PNLiteLocationManager.setLocationTrackingEnabled(true)
        PNLiteLocationManager.setLocationUpdatesEnabled(false)
    }
    
    @objc public var locationTrackingEnabled: Bool {
        get {
            return PNLiteLocationManager.locationTrackingEnabled()
        }
        set (enabled) {
            PNLiteLocationManager.setLocationTrackingEnabled(enabled)
        }
    }
    
    @objc public var locationUpdatesEnabled: Bool {
        get {
            return PNLiteLocationManager.locationUpdatesEnabled()
        }
        set (enabled) {
            PNLiteLocationManager.setLocationUpdatesEnabled(enabled)
        }
    }
}
