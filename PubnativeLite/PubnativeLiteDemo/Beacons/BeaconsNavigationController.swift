// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class BeaconsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let rootViewController = self.viewControllers.first,
              let beaconsViewController = rootViewController as? BeaconsViewController else { return }
        
        beaconsViewController.cleanValues()
    }
}
