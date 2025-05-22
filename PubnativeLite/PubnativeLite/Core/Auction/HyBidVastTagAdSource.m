//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
