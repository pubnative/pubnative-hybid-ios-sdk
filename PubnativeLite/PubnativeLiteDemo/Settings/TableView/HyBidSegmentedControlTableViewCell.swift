// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class HyBidSegmentedControlTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggleSwitch: UICheckbox!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        toggleSwitch.isChecked = false
        segmentedControl.selectedSegmentIndex = 0
    }
}
