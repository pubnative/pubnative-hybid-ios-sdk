// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class BeaconTableViewCell: UITableViewCell {
    
    @IBOutlet weak var beaconTitleLabel: UILabel!
    @IBOutlet weak var beaconContentTextView: UITextView!
    
    private var beacon: HyBidDataModel = HyBidDataModel() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.beaconTitleLabel.text = beacon.type
                self.beaconContentTextView.text = beacon.url ?? beacon.js
            }
        }
    }
    
    func setBeacon(beacon: HyBidDataModel) {
        self.beacon = beacon
    }
}
