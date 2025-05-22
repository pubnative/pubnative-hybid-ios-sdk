// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
