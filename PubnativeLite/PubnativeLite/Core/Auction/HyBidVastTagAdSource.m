////
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

#import "HyBidVastTagAdSource.h"
#import "HyBidAd.h"
#import "PNLiteVastMacrosUtils.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidVastTagAdSource

- (instancetype)initWithConfig:(HyBidAdSourceConfig *)config {
    if (self) {
        self.config = config;
    }
    return self;
}

- (void)fetchAdWithZoneId:(NSString *)zoneId completionBlock:(CompletionBlock)completionBlock {
    PNLiteHttpRequest* request = [[PNLiteHttpRequest alloc]init];
    [request startWithUrlString:[self processTagUrl:self.config.vastTagUrl] withMethod:@"GET" delegate:self];
    self.completionBlock = completionBlock;
}

//MARK: PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    NSString* content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger assetGroup = VAST_MRECT ;
    if (self.adSize == HyBidAdSize.SIZE_INTERSTITIAL) {
        assetGroup = VAST_INTERSTITIAL;
    }
    HyBidAd* ad = [[HyBidAd alloc]initWithAssetGroup:assetGroup withAdContent:content withAdType:kHyBidAdTypeVideo];
    self.completionBlock(ad, nil);
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    self.completionBlock(nil, error);
}

-(NSString*) processTagUrl:(NSString*) tagUrl {
    return [PNLiteVastMacrosUtils formatUrl:tagUrl];
}

@end
