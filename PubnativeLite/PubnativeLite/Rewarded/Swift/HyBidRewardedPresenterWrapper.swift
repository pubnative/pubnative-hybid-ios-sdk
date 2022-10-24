//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
