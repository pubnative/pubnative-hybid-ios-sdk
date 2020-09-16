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

#import <Foundation/Foundation.h>
#import "VWAdvertView.h"
#import "VWAdRequest.h"

@interface VWAdvertView ()

@property (nonatomic, strong)HyBidAdView *adView;

@end

@implementation VWAdvertView

- (void)dealloc {
    self.adView = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.adView = [[HyBidAdView alloc]initWithSize:HyBidAdSize.SIZE_320x50];
}

- (nonnull instancetype)initWithSize:(VWAdSize)size {
    self = [super initWithFrame:CGRectMake(0, 0, size.size.width, size.size.height)];
    if (self) {
        _adLoaded = false;
        self.adView = [[HyBidAdView alloc]initWithSize: [self mapSizes:size]];
        self.adSize = size;
        [self addSubview: self.adView];
    }
    return self;
}

- (nonnull instancetype)initWithSize:(VWAdSize)size origin:(CGPoint)origin {
    self = [super initWithFrame:CGRectMake(0, 0, size.size.width, size.size.height)];
    if (self) {
        _adLoaded = false;
        self.adView = [[HyBidAdView alloc]initWithSize: [self mapSizes:size]];
        self.adSize = size;
        CGRect frame = self.adView.frame;
        frame.origin = origin;
        self.frame = frame;
        [self addSubview: self.adView];
        
    }
    return self;
}

- (void)loadRequestWithZoneID:(NSString *_Nonnull)zoneID andWithRequest:(nonnull VWAdRequest *)request {
    self.adView.contentCategoryIDs = request.contentCategoryIDs;
    [self.adView loadWithZoneID:zoneID andWithDelegate:self];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self sizeThatFits:size];
}

- (HyBidAdSize*)mapSizes:(VWAdSize)size {
    
    if (size.flags == kVWAdSizeBanner.flags) {
        return HyBidAdSize.SIZE_320x50;
    }
    
    if (size.flags == kVWAdSizeMediumRectangle.flags) {
        return HyBidAdSize.SIZE_300x250;
    }
    
    if (size.flags == kVWAdSizeLeaderboard.flags) {
        return HyBidAdSize.SIZE_728x90;
    }
    
    return HyBidAdSize.SIZE_320x50;
}

#pragma mark HyBidAdViewDelegate
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    _adLoaded = false;
    [self.delegate advertView:self didFailToReceiveAdWithError:error];
}

- (void)adViewDidLoad:(HyBidAdView *)adView {
    _adLoaded = true;
    [self.delegate advertViewDidReceiveAd:self];
    [adView show];
}

// TODO
- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    
}

// TODO
- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    
}

@end

