// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

class AnalyticsEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var analyticsEventName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(event: HyBidReportingEvent){
        self.analyticsEventName.text = event.eventType
        self.analyticsEventName.accessibilityIdentifier = event.eventType
    }
}
