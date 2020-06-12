//
//  Copyright © 2018 PubNative. All rights reserved.
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

import UIKit
import HyBid

class VideoInterstitialViewController: UIViewController {

    var videoInterstitial: VWInterstitialVideoAd?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func requestAd() {
        videoInterstitial = VWInterstitialVideoAd()
        videoInterstitial?.allowAudioOnStart = true
        videoInterstitial?.allowAutoPlay = true
        videoInterstitial?.delegate = self
        let adRequest = VWVideoAdRequest(contentCategoryID: VWContentCategory.newsAndInformation)
        adRequest.minDuration = 10
        adRequest.maxDuration = 90
        videoInterstitial?.loadRequest(withZoneID: "6", andWith: adRequest)
    }
    
    @IBAction func requestVideoInterstitialTouchUpInside(_ sender: UIButton) {
        requestAd()
    }
    
    func showAlertControllerWithMessage(for error: String) {
        let alertController = UIAlertController(title: "I have a bad feeling about this... 🙄", message: error, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
            self.requestAd()
        }
        alertController.addAction(dismissAction)
        alertController.addAction(retryAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

extension VideoInterstitialViewController : VWInterstitialVideoAdDelegate {
    func interstitialVideoAdReceive(_ interstitialVideoAd: VWInterstitialVideoAd) {
        print("Video Interstitial did load")
        interstitialVideoAd.present(from: self)
    }
    
    func interstitialVideoAd(_ interstitialVideoAd: VWInterstitialVideoAd, didFailToReceiveAdWithError error: Error?) {
        print("Video Interstitial did fail with error: ",error?.localizedDescription)
        showAlertControllerWithMessage(for: error?.localizedDescription ?? "Something went wrong.")
    }
      
    func interstitialVideoAdWillPresent(_ interstitialVideoAd: VWInterstitialVideoAd) {
        print("Video Interstitial will present")
    }
      
    func interstitialVideoAdWillDismiss(_ interstitialVideoAd: VWInterstitialVideoAd) {
        print("Video Interstitial will dismiss")
    }
      
    func interstitialVideoAdDidDismiss(_ interstitialVideoAd: VWInterstitialVideoAd) {
        print("Video Interstitial did dismiss")
    }
    
}
