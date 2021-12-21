//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "AnalyticsViewController.h"
#import "AnalyticsEventTableViewCell.h"
#import "AnalyticsDetailViewController.h"

@interface AnalyticsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataSource = [[HyBid reportingManager].events sortedArrayUsingComparator:^NSComparisonResult(HyBidReportingEvent* a, HyBidReportingEvent* b) {
        return a.properties[HyBidReportingCommon.TIMESTAMP] > b.properties[HyBidReportingCommon.TIMESTAMP];
    }];
    self.tableView.hidden = !self.dataSource.count;
}

- (void)clearEvents {
    [[HyBid reportingManager] clearEvents];
    self.dataSource = [HyBid reportingManager].events;
    [self.tableView reloadData];
    self.tableView.hidden = !self.dataSource.count;
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDatasource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AnalyticsEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnalyticsEventTableViewCell" forIndexPath:indexPath];
    [cell configureCell:self.dataSource[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AnalyticsDetailViewController *analyticsDetailViewController = [[UIStoryboard storyboardWithName:@"Analytics" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([AnalyticsDetailViewController class])];
    analyticsDetailViewController.event = self.dataSource[indexPath.row];
    analyticsDetailViewController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:analyticsDetailViewController animated:YES completion:nil];
}

@end
