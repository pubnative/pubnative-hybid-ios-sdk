// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

class AnalyticsDetailViewController: UIViewController {

    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var eventJSONTextView: UITextView!
    
    var event: HyBidReportingEvent?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let event else { return }
        eventTypeLabel.text = event.eventType
        eventJSONTextView.text = event.propertiesValue()
    }

    @IBAction func dismissButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


