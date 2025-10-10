//
//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

import Network
import CoreTelephony

final class HyBidNetworkInfoProvider {
    static let shared = HyBidNetworkInfoProvider()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "hybid.network.monitor")
    private var lastPath: NWPath?
    private let lock = NSLock()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.lock.lock()
            self?.lastPath = path
            self?.lock.unlock()
        }
        monitor.start(queue: queue)
    }

    func connectionTypeCode() -> String {
        lock.lock()
        let path = lastPath
        lock.unlock()

        // Not reachable
        guard let path = path, path.status == .satisfied else {
            return "0"
        }

        if path.usesInterfaceType(.wifi) {
            // Wi-Fi
            return "2"
        } else if path.usesInterfaceType(.cellular) {
            let info = CTTelephonyNetworkInfo()
            let tech = info.serviceCurrentRadioAccessTechnology?.values.first
                ?? info.currentRadioAccessTechnology // fallback for older iOS

            guard let carrierType = tech else {
                return "3" // unknown cellular
            }

            switch carrierType {
            case CTRadioAccessTechnologyGPRS,
                 CTRadioAccessTechnologyEdge,
                 CTRadioAccessTechnologyCDMA1x:
                return "4" // 2G
            case CTRadioAccessTechnologyWCDMA,
                 CTRadioAccessTechnologyHSDPA,
                 CTRadioAccessTechnologyHSUPA,
                 CTRadioAccessTechnologyCDMAEVDORev0,
                 CTRadioAccessTechnologyCDMAEVDORevA,
                 CTRadioAccessTechnologyCDMAEVDORevB,
                 CTRadioAccessTechnologyeHRPD:
                return "5" // 3G
            case CTRadioAccessTechnologyLTE:
                return "6" // LTE
            default:
                if #available(iOS 14.1, *) {
                    if carrierType == CTRadioAccessTechnologyNRNSA || carrierType == CTRadioAccessTechnologyNR {
                        return "7" // 5G
                    }
                }
                return "3" // unknown cellular
            }
        } else {
            return "0"
        }
    }

}
