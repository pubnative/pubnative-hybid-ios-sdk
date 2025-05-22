// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class AnalyticsViewController: PNLiteDemoBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var dataSource : [HyBidReportingEvent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var events = HyBid.reportingManager().events
        events = events.sorted { firstElement, secondElement in
            
            guard let firstProperties = firstElement.properties,
                  let firstTimestampString = firstProperties[Common.TIMESTAMP] as? String,
                  let firstTimestampDouble = Double(firstTimestampString) else { return false }
            
            let firstTimestampDate = Date(timeIntervalSince1970: TimeInterval(firstTimestampDouble))
            
            guard let secondProperties = secondElement.properties,
                  let secondTimestampString = secondProperties[Common.TIMESTAMP] as? String,
                  let secondTimestampDouble = Double(secondTimestampString) else { return false }
            
            let secondTimestampDate = Date(timeIntervalSince1970: TimeInterval(secondTimestampDouble))
            
            return firstTimestampDate.compare(secondTimestampDate) == .orderedAscending
        }
            
        self.dataSource = events
    }

    @IBAction func dismissButtonTouchUpInside(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension AnalyticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnalyticsEventTableViewCell") as? AnalyticsEventTableViewCell else {
            return UITableViewCell()
        }
        
        let event = self.dataSource[indexPath.row]
        cell.configureCell(event: event)

        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bundle = Bundle(for: AnalyticsViewController.self)
        let storyboard = UIStoryboard(name: "Analytics", bundle: bundle)
        guard let analyticsDetailViewController = storyboard.instantiateViewController(withIdentifier: "AnalyticsDetailViewController") as? AnalyticsDetailViewController else { return }
        
        analyticsDetailViewController.event = self.dataSource[indexPath.row]
        analyticsDetailViewController.modalPresentationStyle = .popover
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            analyticsDetailViewController.popoverPresentationController?.sourceView = self.view
        }
        
        self.present(analyticsDetailViewController, animated: true)
    }
}
