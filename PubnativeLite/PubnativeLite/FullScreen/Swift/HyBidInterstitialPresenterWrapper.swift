// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

class HyBidInterstitialPresenterWrapper: NSObject, HyBidInterstitialPresenterDelegate {
    
    private weak var parent: HyBidInterstitialAd?

    init(parent: HyBidInterstitialAd) {
        super.init()
        self.parent = parent
    }
    
    func interstitialPresenterDidLoad(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        parent?.interstitialPresenterDidLoad(interstitialPresenter)
    }
    
    func interstitialPresenterDidShow(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        parent?.interstitialPresenterDidShow(interstitialPresenter)
    }
    
    func interstitialPresenterDidClick(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        parent?.interstitialPresenterDidClick(interstitialPresenter)
    }
    
    func interstitialPresenterDidDismiss(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        parent?.interstitialPresenterDidDismiss(interstitialPresenter)
    }
    
    func interstitialPresenterDidFinish(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        parent?.interstitialPresenterDidFinish(interstitialPresenter)
    }
    
    func interstitialPresenter(_ interstitialPresenter: HyBidInterstitialPresenter!, didFailWithError error: Error!) {
        parent?.interstitialPresenter(interstitialPresenter, didFailWithError: error)
    }
    
}

