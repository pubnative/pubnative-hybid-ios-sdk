// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
import Foundation

class HyBidInterstitialSignalDataProcessorWrapper: NSObject, HyBidSignalDataProcessorDelegate {

    private weak var parent: HyBidInterstitialAd?

    init(parent: HyBidInterstitialAd) {
        super.init()
        self.parent = parent
    }

    func signalDataDidFinish(with ad: HyBidAd!) {
        parent?.signalDataDidFinish(with: ad)
    }
    
    func signalDataDidFailWithError(_ error: Error!) {
        parent?.signalDataDidFailWithError(error)
    }
    
}
