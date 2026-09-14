//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAutomaticClickTrackingUtil.h"
#import "HyBidAd.h"

@implementation HyBidAutomaticClickTrackingUtil

+ (BOOL)isAutoClickSuppressedForAd:(HyBidAd *)ad {
    id suppressAutoClick = ad.suppressAutoClick;
    return [suppressAutoClick respondsToSelector:@selector(boolValue)] && [suppressAutoClick boolValue];
}

+ (BOOL)sendClickTrackingURLs:(NSArray<NSString *> *)urls
                withProcessor:(HyBidVASTEventProcessor *)eventProcessor
                  alreadySent:(BOOL)alreadySent {
    if (alreadySent || !eventProcessor || ![urls isKindOfClass:[NSArray class]]) {
        return NO;
    }

    NSMutableArray<NSString *> *validURLs = [NSMutableArray array];
    for (id url in urls) {
        if ([url isKindOfClass:[NSString class]] && [(NSString *)url length] > 0) {
            [validURLs addObject:url];
        }
    }
    if (validURLs.count == 0) {
        return NO;
    }

    [eventProcessor sendVASTUrls:validURLs withType:HyBidVASTClickTrackingURL];
    return YES;
}

+ (BOOL)trackClickEventWithProcessor:(HyBidVASTEventProcessor *)eventProcessor
                      alreadyTracked:(BOOL)alreadyTracked {
    if (alreadyTracked || !eventProcessor) {
        return NO;
    }
    [eventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
    return YES;
}

@end
