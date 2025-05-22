// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

extension UIViewController {
    
    public func showCustomAlert(title: String, message: String? = nil, style: UIAlertController.Style = .alert, firstAction: UIAlertAction? = nil, secondAction: UIAlertAction? = nil, completionHandler: (() -> Void)? = nil){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        if let action = firstAction {
            alertController.addAction(action)
        }
        
        if let action = secondAction {
            alertController.addAction(action)
        }
        
        self.present(alertController, animated: true) {
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
}
