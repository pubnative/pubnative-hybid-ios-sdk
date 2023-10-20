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

import Foundation

// MARK: - UILabel

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
