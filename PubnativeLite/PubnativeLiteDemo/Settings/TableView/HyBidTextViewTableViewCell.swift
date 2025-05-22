// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class HyBidTextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    private var placeholderLabel : UILabel!
    var placeholder = String () {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.sizeToFit()
        }
    }
    
    var textViewHeight: CGFloat = 100 {
        didSet {
            self.textViewHeightConstraint.constant = textViewHeight
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        placeholderLabel = UILabel()
        placeholderLabel.font = .systemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = .gray
        placeholderLabel.alpha = 0.3
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
