//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class BeaconTableViewCell: UITableViewCell {

    @IBOutlet weak var beaconTitleLabel: UILabel!
    @IBOutlet weak var beaconContentTextView: UITextView!

    private var beacon: HyBidBeaconItem? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self, let beacon = self.beacon else { return }
                self.beaconTitleLabel.text = beacon.type
                self.beaconContentTextView.text = beacon.content
            }
        }
    }

    func setBeacon(_ beacon: HyBidBeaconItem) {
        self.beacon = beacon
    }
}
