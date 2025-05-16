// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

class HyBidInterstitialAdRequestWrapper: NSObject, HyBidAdRequestDelegate {

    private weak var parent: HyBidInterstitialAd?
    
    init(parent: HyBidInterstitialAd) {
        super.init()
        self.parent = parent
    }
    
    func requestDidStart(_ request: HyBidAdRequest!) {
        parent?.requestDidStart(request)
    }
    
    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        parent?.request(request, didLoadWithAd: ad)
    }
    
    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        parent?.request(request, didFailWithError: error)
    }
    
}
