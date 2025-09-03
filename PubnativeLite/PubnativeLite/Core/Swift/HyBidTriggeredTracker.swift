//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

private enum HyBidUserInteractionTrackers: String, CaseIterable {
    case click = "click"
    case clickTracking = "ClickTracking"
    case ctaClick = "CTAClick"
    case defaultEndCardClick = "default_endcard_click"
    case customendCardClick = "custom_endcard_click"
    case mute = "mute"
    case unmute = "unmute"
    case skip = "skip"
    case pause = "pause"
    case resume = "resume"
    case rewind = "rewind"
}

@objc
public class HyBidVASTTracker: NSObject {
    
    @objc public let type: String
    @objc public let url: String
    @objc public let beaconName: String?
    private static var triggeredTrackers = [HyBidVASTTracker]()
    private static let serialQueue = DispatchQueue(label: "com.verve.HyBid.serialQueueHyBidVASTTracker")
    public static var safeTriggeredTrackers: [HyBidVASTTracker] {
        HyBidVASTTracker.serialQueue.sync {
            return HyBidVASTTracker.triggeredTrackers
        }
    }
    
    @objc public init(type: String, url: String, beaconName: String? = nil) {
        self.type = type
        self.url = url
        self.beaconName = beaconName
    }
    
    @objc public func shouldBeTriggered() -> Bool {
        if HyBidUserInteractionTrackers.allCases.filter({ $0.rawValue == self.type || $0.rawValue == self.beaconName }).count > 0 {
            return true
        }
        
        return HyBidVASTTracker.safeTriggeredTrackers.filter { $0.type == self.type &&
                                                       $0.url == self.url &&
                                                       $0.beaconName == self.beaconName }.isEmpty
    }
    
    @objc public func addToTriggeredTrackersList() {
        HyBidVASTTracker.serialQueue.async {
            
            guard HyBidUserInteractionTrackers.allCases.filter({ $0.rawValue == self.type || $0.rawValue == self.beaconName }).count == 0 else { return }
            HyBidVASTTracker.triggeredTrackers.append(self)
        }
    }
    
    @objc public static func cleanTriggeredTrackersList() {
        HyBidVASTTracker.serialQueue.sync {
            HyBidVASTTracker.triggeredTrackers.removeAll()
        }
    }
}
