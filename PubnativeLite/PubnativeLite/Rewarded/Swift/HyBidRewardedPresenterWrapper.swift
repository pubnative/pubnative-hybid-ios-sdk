// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
import Foundation

class HyBidRewardedPresenterWrapper: NSObject, HyBidRewardedPresenterDelegate {
    
    private weak var parent: HyBidRewardedAd?

    init(parent: HyBidRewardedAd) {
        super.init()
        self.parent = parent
    }
    
    func rewardedPresenterDidLoad(_ rewardedPresenter: HyBidRewardedPresenter!) {
        parent?.rewardedPresenterDidLoad(rewardedPresenter)
    }
    
    func rewardedPresenterDidShow(_ rewardedPresenter: HyBidRewardedPresenter!) {
        parent?.rewardedPresenterDidShow(rewardedPresenter)
    }
    
    func rewardedPresenterDidClick(_ rewardedPresenter: HyBidRewardedPresenter!) {
        parent?.rewardedPresenterDidClick(rewardedPresenter)
    }
    
    func rewardedPresenterDidDismiss(_ rewardedPresenter: HyBidRewardedPresenter!) {
        parent?.rewardedPresenterDidDismiss(rewardedPresenter)
    }
    
    func rewardedPresenterDidFinish(_ rewardedPresenter: HyBidRewardedPresenter!) {
        parent?.rewardedPresenterDidFinish(rewardedPresenter)
    }
    
    func rewardedPresenter(_ rewardedPresenter: HyBidRewardedPresenter!, didFailWithError error: Error!) {
        parent?.rewardedPresenter(rewardedPresenter, didFailWithError: error)
    }
    
}
