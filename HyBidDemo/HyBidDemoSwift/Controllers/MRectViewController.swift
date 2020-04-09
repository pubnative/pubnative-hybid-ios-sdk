//
//  MRectViewController.swift
//  HyBidDemo
//
//  Created by Fares Ben Hamouda on 09.04.20.
//  Copyright © 2020 Fares Ben Hamouda. All rights reserved.
//

import UIKit
import HyBid

class MRectViewController: UIViewController {

    @IBOutlet weak var bannerAdView: HyBidAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func requestAd() {
        bannerAdView.adSize = HyBidAdSize.size_300x250
        bannerAdView.load(with: self)
    }
    
    @IBAction func loadMRectClicked(_ sender: Any) {
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

extension MRectViewController: HyBidAdViewDelegate {
    
    func adViewDidLoad(_ adView: HyBidAdView!) {
        print("Banner Ad View did load:")
        bannerAdView.show()
    }
    
    func adView(_ adView: HyBidAdView!, didFailWithError error: Error!) {
        print("Banner Ad View did fail with error: ",error.localizedDescription)
        showAlertControllerWithMessage(for: error.localizedDescription)
    }
    
    func adViewDidTrackImpression(_ adView: HyBidAdView!) {
        print("Banner Ad View did track click:");
    }
    
    func adViewDidTrackClick(_ adView: HyBidAdView!) {
        print("Banner Ad View did track impression:");
    }
    
    
}
