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

- (void)openBrowser:(NSString *)urlString {
    NSURL *linkURL = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:linkURL options:@{} completionHandler:nil];
}

- (void)playVideo:(NSString *)urlString {
    NSURL *videoUrl = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:videoUrl options:@{} completionHandler:nil];
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
