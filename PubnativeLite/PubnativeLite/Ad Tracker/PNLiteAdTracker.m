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

#import "PNLiteAdTracker.h"
#import "PNLiteDataModel.h"
@interface PNLiteAdTracker() <PNLiteAdTrackerRequestDelegate>

@property (nonatomic, strong) PNLiteAdTrackerRequest *adTrackerRequest;
@property (nonatomic, strong) NSArray *impressionURLs;
@property (nonatomic, strong) NSArray *clickURLs;
@property (nonatomic, assign) BOOL impressionTracked;
@property (nonatomic, assign) BOOL clickTracked;

@end

@implementation PNLiteAdTracker

- (void)dealloc
{
    self.adTrackerRequest = nil;
    self.impressionURLs = nil;
    self.clickURLs = nil;
}

- (instancetype)initWithImpressionURLs:(NSArray *)impressionURLs
                         withClickURLs:(NSArray *)clickURLs
{
    PNLiteAdTrackerRequest *adTrackerRequest = [[PNLiteAdTrackerRequest alloc] init];
    return [self initWithAdTrackerRequest:adTrackerRequest withImpressionURLs:impressionURLs withClickURLs:clickURLs];
}

- (instancetype)initWithAdTrackerRequest:(PNLiteAdTrackerRequest *)adTrackerRequest
                      withImpressionURLs:(NSArray *)impressionURLs
                           withClickURLs:(NSArray *)clickURLs
{
    self = [super init];
    if (self) {
        self.adTrackerRequest = adTrackerRequest;
        self.impressionURLs = impressionURLs;
        self.clickURLs = clickURLs;
    }
    return self;
}

- (void)trackClick
{
    if (self.clickTracked) {
        return;
    }
    
    [self trackURLs:self.clickURLs withTrackType:@"click"];
    self.clickTracked = YES;
}

- (void)trackImpression
{
    if (self.impressionTracked) {
        return;
    }
    
    [self trackURLs:self.impressionURLs withTrackType:@"impression"];
    self.impressionTracked = YES;
}

- (void)trackURLs:(NSArray *)URLs withTrackType:(NSString *)trackType
{
    for (PNLiteDataModel *dataModel in URLs) {
        NSLog(@"%@", [NSString stringWithFormat:@"Tracking %@ with URL: %@",trackType, dataModel.url]);
        [self.adTrackerRequest trackAdWithDelegate:self withURL:dataModel.url];
    }
}

#pragma mark PNLiteAdTrackerRequestDelegate

- (void)requestDidStart:(PNLiteAdTrackerRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)requestDidFinish:(PNLiteAdTrackerRequest *)request
{
    NSLog(@"Request %@ finished:",request);
}

- (void)request:(PNLiteAdTrackerRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
}


@end
