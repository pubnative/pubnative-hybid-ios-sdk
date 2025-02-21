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
        let storyboard = UIStoryboard(name: "Analytics", bundle: nil)
        guard let analyticsDetailViewController = storyboard.instantiateViewController(withIdentifier: "AnalyticsDetailViewController") as? AnalyticsDetailViewController else { return }
        
        analyticsDetailViewController.event = self.dataSource[indexPath.row]
        analyticsDetailViewController.modalPresentationStyle = .popover
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            analyticsDetailViewController.popoverPresentationController?.sourceView = self.view
        }
        
        self.present(analyticsDetailViewController, animated: true)
    }
}
