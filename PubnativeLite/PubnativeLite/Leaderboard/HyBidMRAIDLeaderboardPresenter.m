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

#import "HyBidMRAIDLeaderboardPresenter.h"
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "HyBidMRAIDServiceProvider.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidLogger.h"

CGFloat const kHyBidMRAIDLeaderboardWidth = 728.0f;
CGFloat const kHyBidMRAIDLeaderboardHeight = 90.0f;

@interface HyBidMRAIDLeaderboardPresenter () <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate>

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, retain) HyBidMRAIDView *mraidView;
@property (nonatomic, strong) HyBidAd *adModel;

@end

@implementation HyBidMRAIDLeaderboardPresenter

- (void)dealloc {
    self.serviceProvider = nil;
    self.adModel = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        self.adModel = ad;
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    self.mraidView = [[HyBidMRAIDView alloc] initWithFrame:CGRectMake(0, 0, kHyBidMRAIDLeaderboardWidth, kHyBidMRAIDLeaderboardHeight)
                                              withHtmlData:self.adModel.htmlData
                                               withBaseURL:[NSURL URLWithString:self.adModel.htmlUrl]
                                         supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsCalendar, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo]
                                             isInterstital:NO
                                                  delegate:self
                                           serviceDelegate:self
                                        rootViewController:[UIApplication sharedApplication].topViewController
                                               contentInfo:self.adModel.contentInfo];
}

- (void)startTracking {
    if (self.mraidView) {
        [self.mraidView startAdSession];
    }
}

- (void)stopTracking {
    if (self.mraidView) {
        [self.mraidView stopAdSession];
    }
}

#pragma mark HyBidMRAIDViewDelegate

- (void)mraidViewAdReady:(HyBidMRAIDView *)mraidView {
    [self.delegate adPresenter:self didLoadWithAd:mraidView];
}

- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView {
    [HyBidLogger error:NSStringFromClass([self class]) withMessage:@"MRAID View failed."];
    NSError *error = [NSError errorWithDomain:@"MRAID View failed." code:0 userInfo:nil];
    [self.delegate adPresenter:self didFailWithError:error];
}

- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debug:NSStringFromClass([self class]) withMessage:@"MRAID will expand."];
    [self.delegate adPresenterDidClick:self];
}

- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debug:NSStringFromClass([self class]) withMessage:@"MRAID did close."];
}

- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url {
    [HyBidLogger debug:NSStringFromClass([self class]) withMessage:[NSString stringWithFormat:@"MRAID navigate with URL:%@",url]];
    [self.serviceProvider openBrowser:url.absoluteString];
    [self.delegate adPresenterDidClick:self];
}

- (BOOL)mraidViewShouldResize:(HyBidMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen {
    return NO;
}

#pragma mark HyBidMRAIDServiceDelegate

- (void)mraidServiceCallNumberWithUrlString:(NSString *)urlString {
    [self.serviceProvider callNumber:urlString];
}

- (void)mraidServiceSendSMSWithUrlString:(NSString *)urlString {
    [self.serviceProvider sendSMS:urlString];
}

- (void)mraidServiceCreateCalendarEventWithEventJSON:(NSString *)eventJSON {
    [self.serviceProvider createEvent:eventJSON];
}

- (void)mraidServiceOpenBrowserWithUrlString:(NSString *)urlString {
    [self.delegate adPresenterDidClick:self];
    [self.serviceProvider openBrowser:urlString];
}

- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString {
    [self.serviceProvider playVideo:urlString];
}

- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString {
    [self.serviceProvider storePicture:urlString];
}

@end
