// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidMRAIDServiceProvider.h"
#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

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
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusAuthorized) {
        [self downloadImageWithURL:[NSURL URLWithString:urlString] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
        }];
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
      {
          if (!error) {
              UIImage *image = [[UIImage alloc] initWithData:data];
              completionBlock(YES,image);
          } else {
              if ([HyBidSDKConfig sharedConfig].reporting) {
                  HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                  [[HyBid reportingManager] reportEventFor:reportingEvent];
              }
              completionBlock(NO,nil);
          }
      }] resume];
}

- (void)sendSMS:(NSString *)urlString {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"sms:" stringByAppendingString:urlString]] options:@{} completionHandler:nil];
}

- (void)callNumber:(NSString *)urlString {
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:urlString]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:urlString]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl options:@{} completionHandler:nil];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [[UIApplication sharedApplication] openURL:phoneFallbackUrl options:@{} completionHandler:nil];
    } else {
        // Show an error message: Your device can not do phone calls.
    }
}

@end
