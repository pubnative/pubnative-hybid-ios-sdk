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
public class HyBidImpressionConstants: NSObject {
    
    // Placement position
    @objc public static let PLACEMENT_POSITION_UNKNOWN = "0"
    @objc public static let PLACEMENT_POSITION_FULLSCREEN = "7"
    
    // Expandable direction
    @objc public static let EXPANDABLE_DIRECTION_FULLSCREEN = "5"
    @objc public static let EXPANDABLE_DIRECTION_RESIZE_MINIMIZE = "6"
    
    // Video placement type
    @objc public static let VIDEO_PLACEMENT_TYPE_INTERSTITIAL = "5"
    
    // Video placement subtype
    @objc public static let VIDEO_PLACEMENT_SUBTYPE_INTERSTITIAL = "3"
    @objc public static let VIDEO_PLACEMENT_SUBTYPE_STANDALONE = "4"
    
    // Video playback method
    @objc public static let VIDEO_PLAYBACK_METHOD_PAGE_LOAD_SOUND_ON = "1"
    @objc public static let VIDEO_PLAYBACK_METHOD_PAGE_LOAD_SOUND_OFF = "2"
    @objc public static let VIDEO_PLAYBACK_METHOD_ENTER_VIEWPORT_SOUND_ON = "5"
    @objc public static let VIDEO_PLAYBACK_METHOD_ENTER_VIEWPORT_SOUND_OFF = "6"
}
