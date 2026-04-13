//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc(HyBidBeaconsInspector)
public class HyBidBeaconsInspector: NSObject {

    @objc public static let shared = HyBidBeaconsInspector()

    private let lock = NSLock()
    private var responseOverride: String?

    private override init() {
        super.init()
    }

    // MARK: - Public API

    @objc public func setResponseForBeaconsInspector(_ response: String?) {
        lock.lock()
        defer { lock.unlock() }
        responseOverride = response
    }

    @objc public func firedBeacons() -> [HyBidBeaconItem] {
        let beacons = HyBidReportingManager.sharedInstance.beacons
        let vastTrackers = HyBidReportingManager.sharedInstance.vastTrackers
        let beaconsModel = beacons.map { HyBidDataModel(dictionary: $0.properties ?? [:]) }
        let vastTrackersModel = vastTrackers.map { HyBidDataModel(dictionary: $0.properties ?? [:]) }
        let allBeacons = beaconsModel + vastTrackersModel
        var items = allBeacons.compactMap { model -> HyBidBeaconItem? in
            guard let model = model else { return nil }
            return HyBidBeaconItem(
                type: (model.type ?? "").firstCapitalized,
                url: model.url,
                js: model.js
            )
        }
        items.sort { a, b in
            if a.type != b.type { return a.type < b.type }
            let ac = a.url ?? a.js ?? ""
            let bc = b.url ?? b.js ?? ""
            return ac < bc
        }
        return items
    }

    @objc public func adBeaconsFromLastResponse(completion: @escaping ([HyBidBeaconItem]) -> Void) {
        lock.lock()
        let response = responseOverride
        lock.unlock()

        let mapDictsToItems: (NSArray?) -> [HyBidBeaconItem] = { dicts in
            let array = (dicts as? [NSDictionary]) ?? []
            return array.map { dict in
                let type = (dict["type"] as? String) ?? ""
                let url = dict["url"] as? String
                let js = dict["js"] as? String
                return HyBidBeaconItem(type: type, url: url, js: js)
            }
        }

        if let response = response {
            HyBidBeaconsInspectorHelper.adBeaconDictionaries(fromResponse: response, completion: { completion(mapDictsToItems($0 as NSArray?)) })
        } else {
            HyBidBeaconsInspectorHelper.adBeaconDictionariesFromLastResponse(completion: { completion(mapDictsToItems($0 as NSArray?)) })
        }
    }

    @objc public func adBeacons(fromResponse response: String?, completion: @escaping ([HyBidBeaconItem]) -> Void) {
        HyBidBeaconsInspectorHelper.adBeaconDictionaries(fromResponse: response, completion: { dicts in
            let array = (dicts as? [NSDictionary]) ?? []
            let items = array.map { dict -> HyBidBeaconItem in
                let type = (dict["type"] as? String) ?? ""
                let url = dict["url"] as? String
                let js = dict["js"] as? String
                return HyBidBeaconItem(type: type, url: url, js: js)
            }
            completion(items)
        })
    }

}

private extension StringProtocol {
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
