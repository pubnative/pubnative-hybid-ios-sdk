// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@objc
public class HyBidMRAIDCommand: NSObject {
    
    @objc
    public enum HyBidMRAIDCommandType: Int32 {
        case mraid
        case verveAdExperience
        case consoleLog
        
        case unknown
        
        var stringValue: String {
            switch self {
            case .mraid: return "mraid"
            case .verveAdExperience: return "verveadexperience"
            case .consoleLog: return "console-Log"
            case .unknown: return "unknown"
            }
        }
    }
    
    @available(*, unavailable)
    public override init() {
        super .init()
    }
    
    @objc public func commandTypeWith(text: String) -> HyBidMRAIDCommandType {
        switch text {
        case HyBidMRAIDCommandType.mraid.stringValue: return .mraid
        case HyBidMRAIDCommandType.verveAdExperience.stringValue: return .verveAdExperience
        case HyBidMRAIDCommandType.consoleLog.stringValue: return .consoleLog
        default: return .unknown
        }
    }
}
