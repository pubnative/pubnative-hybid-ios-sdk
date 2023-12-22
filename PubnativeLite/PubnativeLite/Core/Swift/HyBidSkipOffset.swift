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
public class HyBidSkipOffset: NSObject {
    
    @objc public static let DEFAULT_VIDEO_SKIP_OFFSET = 10
    @objc public static let DEFAULT_HTML_SKIP_OFFSET = 3
    @objc public static let DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD = 15
    @objc public static let DEFAULT_END_CARD_CLOSE_OFFSET = 3
    @objc public static let DEFAULT_REWARDED_VIDEO_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_INTERSTITIAL_VIDEO_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_REWARDED_HTML_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_INTERSTITIAL_HTML_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_NATIVE_CLOSE_BUTTON_OFFSET = 15

    @objc public var offset: NSNumber?
    @objc public var isCustom: Bool = false
    @objc public var style: NSNumber = 0
    
    @objc
    public init(offset: NSNumber?, isCustom: Bool) {
        super.init()
        configure(offset: offset, isCustom: isCustom, style: 0)
    }
    
    @objc
    public init(offset: NSNumber?, isCustom: Bool, style: NSNumber = 0) {
        super.init()
        configure(offset: offset, isCustom: isCustom, style: style)
    }

    @objc
    public func configure(offset: NSNumber?, isCustom: Bool, style: NSNumber = 0) {
        if offset?.intValue ?? 0 > 99 {
            self.offset = NSNumber(value: 99)
        } else {
            self.offset = offset
        }
        self.isCustom = isCustom
        self.style = style
    }
}
