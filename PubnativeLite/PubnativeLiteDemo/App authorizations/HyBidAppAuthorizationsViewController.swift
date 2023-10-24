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

import UIKit
import CoreLocation
import AppTrackingTransparency

class HyBidAppAuthorizationsViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var appAuthorizationsTableView: UITableView!
    
    // MARK: Variables
    private var locationManager: CLLocationManager?
    private var appAuthorizations = HyBidAppAuthorizationType.allCases.map { return HyBidAppAuthorization(type: $0) }
    private let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appAuthorizationsTableView.delegate = self
        self.appAuthorizationsTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive(){
        self.reloadData()
    }
    
    private func requestLocationAuthorization(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    
    private func requestTrackingAuthorization(){
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    print("IDFA Tracking permission not determined.");
                case .restricted:
                    print("IDFA Tracking restricted.");
                case .denied:
                    print("IDFA Tracking denied.");
                case .authorized:
                    print("IDFA Tracking authorized.");
                @unknown default:
                    print("IDFA Tracking unknown value.");
                }
                
                self.reloadData()
            }
        }
    }
    
    private func reloadData(){
        DispatchQueue.main.async { [weak self] in
            self?.appAuthorizations = HyBidAppAuthorizationType.allCases.map { return HyBidAppAuthorization(type: $0) }
            self?.appAuthorizationsTableView.reloadData()
        }
    }
}

// MARK: Extensions

extension HyBidAppAuthorizationsViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.reloadData()
    }
}

extension HyBidAppAuthorizationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appAuthorizations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "HyBidAppAuthorizationsTableViewCell")
        
        let appAuthorization = appAuthorizations[indexPath.row]
        self.setCellValues(cell: cell, appAuthorization: appAuthorization)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let appAuthorization = appAuthorizations[indexPath.row]
        self.setCellButtonAction(appAuthorization: appAuthorization)
    }
    
    private func setCellValues(cell: UITableViewCell, appAuthorization: HyBidAppAuthorization){
        let appAuthorizationType = String(describing: appAuthorization.type)
        if let detailsText = appAuthorization.detailsString() {
            cell.textLabel?.text = "\(appAuthorizationType) - (\(detailsText))"
            cell.textLabel?.font = .systemFont(ofSize: cell.detailTextLabel?.font.pointSize ?? 12)
            cell.textLabel?.numberOfLines = 0
        } else {
            cell.textLabel?.text = appAuthorizationType
        }
        cell.textLabel?.changeTextFont(text: appAuthorizationType, font: .boldSystemFont(ofSize: 17))
        cell.detailTextLabel?.text = appAuthorization.status.rawValue
        cell.detailTextLabel?.font = .italicSystemFont(ofSize: cell.detailTextLabel?.font.pointSize ?? 12)
        if appAuthorization.type == .tracking, #unavailable(iOS 14) { return }
        cell.accessoryType = .detailButton
    }
    
    private func setCellButtonAction(appAuthorization: HyBidAppAuthorization){
        var action: UIAlertAction?
        let message = appAuthorization.status == .notDetermined ?
        "Do you want to set the \(appAuthorization.type) authorization status?" :
        "Do you want to change the \(appAuthorization.type) authorization status? (you'll be redirected to the config section)"
        
        action = getAlertActionBaseOn(type: appAuthorization.type, isAuthorizationNotDetermined: appAuthorization.status == .notDetermined)
        
        self.showCustomAlert(title: "Status - \(appAuthorization.status.rawValue)", message: message,firstAction: action, secondAction: cancelAction)
    }
    
    private func getAlertActionBaseOn(type: HyBidAppAuthorizationType, isAuthorizationNotDetermined: Bool) -> UIAlertAction? {
        var action: UIAlertAction?
        
        if isAuthorizationNotDetermined {
            action = UIAlertAction(title: "Request \(type)", style: .default) { [weak self] _ in
                switch type {
                case .location:
                    self?.requestLocationAuthorization()
                case .tracking:
                    self?.requestTrackingAuthorization()
                }
            }
        } else {
            action = UIAlertAction(title: "Change status", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
            }
        }

        return action
    }
}
