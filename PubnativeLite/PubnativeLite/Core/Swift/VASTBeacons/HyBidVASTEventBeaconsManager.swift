// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

@objc
public class HyBidVASTEventBeaconsManager: NSObject {
    
    @objc public static let shared = HyBidVASTEventBeaconsManager()
    private let eventTypeMacro = "[EVENTTYPE]"
    private let onTopOfMacro = "[ONTOPOF]"
    private let errorCodeMacro = "[ERRORCODE]"
    private let vastSDKeventsList: [HyBidVASTsdkEvent] = [
        //MARK: - LOAD_EVENTS
        HyBidVASTsdkEvent(name: EventType.LOAD, vastEventBeaconType: .sdk_event),
        HyBidVASTsdkEvent(name: EventType.LOAD_FAIL, vastEventBeaconType: .sdk_event),
        HyBidVASTsdkEvent(name: EventType.SHOW, vastEventBeaconType: .sdk_event),
        HyBidVASTsdkEvent(name: EventType.REPLAY, vastEventBeaconType: .sdk_event)
    ]
    
    private let vastAuxiliaryAdEvent: [HyBidVASTauxiliaryAdEvent] = [
        //MARK: - COMPANION_AD_EVENTS
        HyBidVASTauxiliaryAdEvent(name: EventType.DEFAULT_ENDCARD_IMPRESSION, vastEventBeaconType: .companion_ad_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.DEFAULT_ENDCARD_IMPRESSION_ERROR, vastEventBeaconType: .companion_ad_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.DEFAULT_ENDCARD_SKIP, vastEventBeaconType: .companion_ad_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.DEFAULT_ENDCARD_CLOSE, vastEventBeaconType: .companion_ad_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.DEFAULT_ENDCARD_CLICK, vastEventBeaconType: .companion_ad_event),
        
        //MARK: - CUSTOM_ENDCARD_EVENTS
        HyBidVASTauxiliaryAdEvent(name: EventType.CUSTOM_ENDCARD_IMPRESSION, vastEventBeaconType: .custom_endcard_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.CUSTOM_ENDCARD_IMPRESSION_ERROR, vastEventBeaconType: .custom_endcard_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.CUSTOM_ENDCARD_CLOSE, vastEventBeaconType: .custom_endcard_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.CUSTOM_ENDCARD_CLICK, vastEventBeaconType: .custom_endcard_event),
        
        //MARK: - SKOVERLAY_EVENTS
        HyBidVASTauxiliaryAdEvent(name: EventType.SKOVERLAY_IMPRESSION, vastEventBeaconType: .skoverlay_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.SKOVERLAY_IMPRESSION_ERROR, vastEventBeaconType: .skoverlay_event),
        
        //MARK: - AUTOSTOREKIT_EVENTS
        HyBidVASTauxiliaryAdEvent(name: EventType.AUTO_STORE_KIT_IMPRESSION, vastEventBeaconType: .autostorekit_event),
        HyBidVASTauxiliaryAdEvent(name: EventType.AUTO_STORE_KIT_IMPRESSION_ERROR, vastEventBeaconType: .autostorekit_event),
    ]
    
    private func addMacrosTo(beaconURL: String,
                             vastEventBeacon: HyBidVASTEventBeaconsType,
                             sdkEventType: HyBidSDKEventType? = nil,
                             auxiliaryAdEventType: HyBidAuxiliaryAdEventType? = nil,
                             onTopOfType: HyBidOnTopOfType? = nil,
                             errorCode: Int? = nil) -> String {
        var urlString = beaconURL
        
        switch vastEventBeacon {
        case .sdk_event:
            let eventTypeValue = sdkEventType ?? .UNKNOWN_SDK_EVENT
            urlString = urlString.replacingOccurrences(of: eventTypeMacro, with: eventTypeValue.stringValue())
        case .companion_ad_event, .custom_endcard_event, .autostorekit_event, .skoverlay_event:
            let eventTypeValue = auxiliaryAdEventType ?? .UNKNOWN_AUXILIARY_AD_EVENT
            urlString = urlString.replacingOccurrences(of: eventTypeMacro, with: eventTypeValue.stringValue())
            
            if vastEventBeacon == .autostorekit_event || vastEventBeacon == .skoverlay_event {
                let onTopOfValue = onTopOfType ?? .UNKNOWN_TOP_EVENT
                urlString = urlString.replacingOccurrences(of: onTopOfMacro, with: onTopOfValue.stringValue())
            }
        }
        
        if let errorCode = errorCode {
            urlString = urlString.replacingOccurrences(of: errorCodeMacro, with: String(errorCode))
        }

        return urlString
    }
    
    private func getURLFrom(ad: HyBidAd?, vastEventBeacon: HyBidVASTEventBeaconsType) -> String? {
        guard let ad = ad,
              let beacons = ad.beacons,
              let beacon = beacons.first(where: { $0.type == vastEventBeacon.stringValue() }),
              let eventURL = beacon.url else { return nil }
        return eventURL
    }
    
    @objc
    public func reportVASTEvent(type: String, ad: HyBidAd?) {
        self.reportVASTEventWith(type: type, ad: ad, onTopOf: .UNKNOWN_TOP_EVENT, errorCode: .none)
    }
    
    @objc
    public func reportVASTEvent(type: String, ad: HyBidAd?, errorCode: Int) {
        self.reportVASTEventWith(type: type, ad: ad, onTopOf: .UNKNOWN_TOP_EVENT, errorCode: errorCode)
    }
    
    @objc
    public func reportVASTEvent(type: String, ad: HyBidAd?, onTopOf: HyBidOnTopOfType) {
        self.reportVASTEventWith(type: type, ad: ad, onTopOf: onTopOf, errorCode: .none)
    }
    
    @objc
    public func reportVASTEvent(type: String, ad: HyBidAd?, onTopOf: HyBidOnTopOfType, errorCode: Int) {
        self.reportVASTEventWith(type: type, ad: ad, onTopOf: onTopOf, errorCode: errorCode)
    }
    
    private func reportVASTEventWith(type: String, ad: HyBidAd?, onTopOf:HyBidOnTopOfType, errorCode: Int? = nil) {
        var urlForRequest = String()
        guard let ad, let assetGroupID = ad.isUsingOpenRTB ? ad.openRTBAssetGroupID : ad.assetGroupID,
              (assetGroupID.intValue == VAST_MRECT ||
               assetGroupID.intValue == VAST_INTERSTITIAL ||
               assetGroupID.intValue == VAST_REWARDED) else { return }
        
        var vastEventBeaconType = "Unknown Beacon"
        if let sdkEvent = vastSDKeventsList.first(where: { $0.name == type } ) {
            if let eventURL = getURLFrom(ad: ad, vastEventBeacon: sdkEvent.vastEventBeaconType) {
                vastEventBeaconType = sdkEvent.vastEventBeaconType.stringValue()
                urlForRequest = addMacrosTo(beaconURL: eventURL,
                                            vastEventBeacon: sdkEvent.vastEventBeaconType,
                                            sdkEventType: sdkEvent.sdkEventType(),
                                            errorCode: errorCode)
            }
            
        } else if let auxiliaryEvent = vastAuxiliaryAdEvent.first(where: { $0.name == type } ) {
            if let eventURL = getURLFrom(ad: ad, vastEventBeacon: auxiliaryEvent.vastEventBeaconType) {
                vastEventBeaconType = auxiliaryEvent.vastEventBeaconType.stringValue()
                urlForRequest = addMacrosTo(beaconURL: eventURL,
                                            vastEventBeacon: auxiliaryEvent.vastEventBeaconType,
                                            auxiliaryAdEventType: auxiliaryEvent.auxiliaryAdEventType(),
                                            onTopOfType: onTopOf,
                                            errorCode: errorCode)
            }
        }
        
        if !urlForRequest.isEmpty {
            HyBidVASTEventProcessor().sendVASTBeaconUrl(urlForRequest, withTrackingType: vastEventBeaconType, beaconName: type)
        }
    }
}
