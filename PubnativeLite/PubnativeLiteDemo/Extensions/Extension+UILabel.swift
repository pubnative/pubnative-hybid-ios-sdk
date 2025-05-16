// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

extension UILabel {
    
    public func changeTextFont(text: String, font: UIFont) {
        
        guard let labelText = self.text else {
            return
        }
        
        let textToModify = (labelText as NSString).range(of: text)
        let attributedString = NSMutableAttributedString(string: labelText)

        if #available(iOS 13.0, *) {
            attributedString.setAttributes([NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : UIColor.label], range: textToModify)
        } else {
            attributedString.setAttributes([NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : UIColor.black], range: textToModify)
        }
        
        self.attributedText = attributedString
    }
}
