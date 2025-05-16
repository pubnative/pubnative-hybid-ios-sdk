// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class BeaconsTextListViewController: UIViewController {
    
    //MARK: - Variables
    var beaconsListText = String()
    
    //MARK: - Outlets
    @IBOutlet weak var beaconsTextListTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beaconsTextListTextView.text = beaconsListText
    }
    
    @IBAction func dismissButtonTouchUpInside(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
