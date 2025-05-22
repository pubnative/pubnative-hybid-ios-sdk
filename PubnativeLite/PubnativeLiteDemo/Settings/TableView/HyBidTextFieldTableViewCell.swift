// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class HyBidTextFieldTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggleSwitch: UICheckbox!
    @IBOutlet var textField: UITextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        toggleSwitch.isChecked = false
        textField.text = ""
    }
}

