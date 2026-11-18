// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidMRAIDServiceProvider.h"
#import <UIKit/UIKit.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidMRAIDServiceProvider

#pragma mark - URL helper

- (NSURL *)safeURLFromObject:(id)value {
    if (![value isKindOfClass:[NSString class]]) { return nil; }

    NSString *string = (NSString *)value;
    if (string.length == 0) { return nil; }

    NSURL *url = [NSURL URLWithString:string];
    if (!url) {
        NSString *encoded =
        [string stringByAddingPercentEncodingWithAllowedCharacters:
         [NSCharacterSet URLQueryAllowedCharacterSet]];
        if (encoded.length > 0) {
            url = [NSURL URLWithString:encoded];
        }
    }

    if (!url || url.scheme.length == 0) { return nil; }

    return url;
}

- (void)openBrowser:(NSString *)urlString {
    NSURL *linkURL = [self safeURLFromObject:urlString];
    if (!linkURL) { return; }
    [[UIApplication sharedApplication] openURL:linkURL options:@{} completionHandler:nil];
}

- (void)playVideo:(NSString *)urlString {
    NSURL *videoURL = [self safeURLFromObject:urlString];
    if (!videoURL) { return; }
    [[UIApplication sharedApplication] openURL:videoURL options:@{} completionHandler:nil];
}

- (void)storePicture:(NSString *)urlString {
    // mraid.storePicture is not supported: HyBid never writes to the user's photo library.
    [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"storePicture is not supported."];
}

- (void)sendSMS:(NSString *)urlString {
    if (![urlString isKindOfClass:[NSString class]] || urlString.length == 0) { return; }
    NSURL *smsUrl = [NSURL URLWithString:[@"sms:" stringByAppendingString:urlString]];
    if (!smsUrl) { return; }
    [[UIApplication sharedApplication] openURL:smsUrl options:@{} completionHandler:nil];
}

- (void)callNumber:(NSString *)urlString {
    if (![urlString isKindOfClass:[NSString class]] || urlString.length == 0) { return; }
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:urlString]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:urlString]];

    if (phoneUrl && [UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:nil];
    } else if (phoneFallbackUrl && [UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [[UIApplication sharedApplication] openURL:phoneFallbackUrl options:@{} completionHandler:nil];
    } else {
        // Show an error message: Your device can not do phone calls.
    }
}

@end
