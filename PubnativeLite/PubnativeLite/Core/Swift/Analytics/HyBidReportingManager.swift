// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public protocol HyBidReportingDelegate: AnyObject {
    func onEvent(with event: HyBidReportingEvent)
    func onBeacon(with beacon: HyBidReportingBeacon)
    func onVASTTracker(with tracker: HyBidReportingVASTTracker)
}

@objc
public class HyBidReportingManager: NSObject {
    
    @objc public static let sharedInstance = HyBidReportingManager()
    
    @objc public var events: [HyBidReportingEvent] = []
    @objc weak public var delegate: HyBidReportingDelegate?
    @objc public var isAtomStarted: Bool = false
    private let eventsQueue = DispatchQueue(label: "com.verve.HyBid.eventsQueue", target: nil)
    
    @objc public var beacons: [HyBidReportingBeacon] = []
    private let beaconsQueue = DispatchQueue(label: "com.verve.HyBid.beaconsQueue", target: nil)
    
    @objc public var vastTrackers: [HyBidReportingVASTTracker] = []
    private let vastTrackersQueue = DispatchQueue(label: "com.verve.HyBid.beaconsQueue", target: nil)
    
    @objc
    public func reportEvent(for event: HyBidReportingEvent) {
        guard HyBidSDKConfig.sharedConfig.reporting == true else { return }
        eventsQueue.async { [weak self] in
            guard let self = self else { return }
            self.events.append(event)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.onEvent(with: event)
            }
        }
    }
    
    @objc
    public func reportEvents(for events: [HyBidReportingEvent]) {
        guard HyBidSDKConfig.sharedConfig.reporting == true else { return }
        eventsQueue.async { [weak self] in
            guard let self = self else { return }
            self.events.append(contentsOf: events)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for event in events {
                    self.delegate?.onEvent(with: event)
                }
            }
        }
    }
    
    @objc
    public func clearAllReports() {
        eventsQueue.async { [weak self] in
            guard let self = self else { return }
            self.events.removeAll()
            self.beacons.removeAll()
            self.vastTrackers.removeAll()
        }
    }
    
    @objc
    public func clearEvents() {
        eventsQueue.async { [weak self] in
            guard let self = self else { return }
            self.events.removeAll()
        }
    }
    
    @objc
    public func addCommonProperties(forAd ad: HyBidAd?, withRequest request: HyBidAdRequest?) -> [String: String] {
        var commonProperties = [String: String]()
        if HyBidSDKConfig.sharedConfig.reporting == true {
            if let appToken = HyBidSDKConfig.sharedConfig.appToken, appToken.count > 0 {
                commonProperties[Common.APPTOKEN] = appToken
            }
            
            if request != nil {
                if let integrationType = request?.integrationType, let integrationTypeString = HyBidIntegrationType.integrationType(toString: integrationType), integrationTypeString.count > 0 {
                    commonProperties[Common.INTEGRATION_TYPE] = integrationTypeString
                }
                
                if let adSize = request?.adSize, adSize.description.count > 0 {
                    commonProperties[Common.AD_SIZE] = adSize.description
                }
            }
            
            if ad != nil {
                if let zoneID = ad?.zoneID, zoneID.count > 0 {
                    commonProperties[Common.ZONE_ID] = zoneID
                }
                
                var assetGroupId: NSInteger = 0;
                if ad?.isUsingOpenRTB != nil && ad?.isUsingOpenRTB == true {
                    assetGroupId = NSInteger(truncating: ad?.openRTBAssetGroupID ?? 0)
                } else {
                    assetGroupId = NSInteger(truncating: ad?.assetGroupID ?? 0)
                }
                
                switch UInt32(assetGroupId) {
                case VAST_MRECT, VAST_REWARDED, VAST_INTERSTITIAL:
                    commonProperties[Common.AD_TYPE] = "VAST"
                    if let vastString = ad?.vast {
                        commonProperties[Common.CREATIVE] = vastString
                    }
                    break
                default:
                    commonProperties[Common.AD_TYPE] = "HTML"
                    if let htmlDataString = ad?.htmlData {
                        commonProperties[Common.CREATIVE] = htmlDataString
                    }
                    break
                }
            }
        }
        return commonProperties
    }
    
    @objc
    public func reportBeacon(for beacon: HyBidReportingBeacon) {
        guard HyBidSDKConfig.sharedConfig.reporting == true else { return }
        beaconsQueue.async { [weak self] in
            guard let self else { return }
            self.beacons.append(beacon)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.onBeacon(with: beacon)
            }
        }
    }
    
    @objc
    public func clearBeacons() {
        beaconsQueue.async { [weak self] in
            guard let self else { return }
            self.beacons.removeAll()
        }
    }
    
    @objc
    public func reportVASTTracker(for tracker: HyBidReportingVASTTracker) {
        guard HyBidSDKConfig.sharedConfig.reporting == true else { return }
        vastTrackersQueue.async { [weak self] in
            guard let self else { return }
            self.vastTrackers.append(tracker)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.onVASTTracker(with: tracker)
            }
        }
    }
}
