//
//  BannerViewController.swift
//  HyBidDemo
//
//  Created by Fares Ben Hamouda on 09.04.20.
//  Copyright © 2020 Fares Ben Hamouda. All rights reserved.
//

import UIKit
import HyBid
import CoreLocation

class BannerViewController: UIViewController {

    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var bannerAdView: VWAdvertView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestLocation()
    }
    
    @IBAction func loadAdButtonClicked(_ sender: Any) {
        requestAd()
    }
    
    func requestAd() {
        bannerAdView.delegate = self
        bannerAdView.adSize = kVWAdSizeBanner
        bannerAdView.load(VWAdRequest(contentCategoryID: .artsAndEntertainment))
    }
    
    func requestLocation() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
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

extension BannerViewController: VWAdvertViewDelegate {
    
    func advertViewDidReceiveAd(_ adView: VWAdvertView) {
        print("Banner Ad View did load:")
    }
    
    func advertView(_ adView: VWAdvertView, didFailToReceiveAdWithError error: Error?) {
        print("Banner Ad View did fail with error: ", error?.localizedDescription ?? "")
        showAlertControllerWithMessage(for: error?.localizedDescription ?? "")
    }
    
    
}
