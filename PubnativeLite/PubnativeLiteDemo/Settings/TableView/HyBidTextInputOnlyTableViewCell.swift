// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class HyBidTextInputOnlyTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = ""
    }
}

