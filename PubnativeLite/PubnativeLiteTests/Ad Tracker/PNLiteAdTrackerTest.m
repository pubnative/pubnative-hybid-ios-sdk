//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "HyBidAdTracker.h"
#import "PNLiteTestUtil.h"

@interface HyBidAdTracker()

@property (retain) PNLiteAdTrackerRequest *adTrackerRequest;

@end

@interface PNLiteAdTrackerTest : XCTestCase

@property (nonatomic, strong) HyBidAdTracker *adTracker;

@end

@implementation PNLiteAdTrackerTest

- (void)setUp
{
    [super setUp];
    self.adTracker = [[HyBidAdTracker alloc] initWithImpressionURLs:[[PNLiteTestUtil sharedInstance] createMockImpressionBeaconArray]
                                                       withClickURLs:[[PNLiteTestUtil sharedInstance] createMockClickBeaconArray]];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_trackImpression
{
    PNLiteAdTrackerRequest *adTrackerRequest = mock([PNLiteAdTrackerRequest class]);
    self.adTracker.adTrackerRequest = adTrackerRequest;
    [self.adTracker trackImpression];
    [self.adTracker trackImpression];
    [verifyCount(self.adTracker.adTrackerRequest, times(1)) trackAdWithDelegate:((id<PNLiteAdTrackerRequestDelegate>)self.adTracker) withURL:@"validImpressionURL"];
}

- (void)test_trackClick
{
    PNLiteAdTrackerRequest *adTrackerRequest = mock([PNLiteAdTrackerRequest class]);
    self.adTracker.adTrackerRequest = adTrackerRequest;
    [self.adTracker trackClick];
    [self.adTracker trackClick];
    [verifyCount(self.adTracker.adTrackerRequest, times(1)) trackAdWithDelegate:((id<PNLiteAdTrackerRequestDelegate>)self.adTracker) withURL:@"validClickURL"];
}

@end
