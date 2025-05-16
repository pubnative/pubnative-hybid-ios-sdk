// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class HyBidSwitchTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggleSwitch: UICheckbox!
    @IBOutlet var additionalSwitch: UISwitch!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        toggleSwitch.isChecked = false
        additionalSwitch.isOn = false
    }
}
