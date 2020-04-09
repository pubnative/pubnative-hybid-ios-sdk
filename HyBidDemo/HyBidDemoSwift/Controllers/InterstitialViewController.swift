//
//  InterstitialViewController.swift
//  HyBidDemo
//
//  Created by Fares Ben Hamouda on 09.04.20.
//  Copyright © 2020 Fares Ben Hamouda. All rights reserved.
//

import UIKit
import HyBid

class InterstitialViewController: UIViewController {

    var interstitialAd: HyBidInterstitialAd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitialAd = HyBidInterstitialAd(delegate: self)
    }

    func requestAd() {
        interstitialAd.load()
    }
    
    @IBAction func requestInterstitialTouchUpInside(_ sender: Any) {
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

extension InterstitialViewController: HyBidInterstitialAdDelegate {
    
    func interstitialDidLoad() {
        print("Interstitial did load")
        interstitialAd.show()
    }
    
    func interstitialDidFailWithError(_ error: Error!) {
        print("Interstitial did fail with error: ",error.localizedDescription)
        showAlertControllerWithMessage(for: error.localizedDescription)
    }
    
    func interstitialDidTrackImpression() {
        print("Interstitial did track click")
    }
    
    func interstitialDidTrackClick() {
        print("Interstitial did track impression")
    }
    
    func interstitialDidDismiss() {
        print("Interstitial did dismiss")
    }
    
}
