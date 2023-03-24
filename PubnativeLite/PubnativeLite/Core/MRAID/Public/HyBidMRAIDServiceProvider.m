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
              HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
              [[HyBid reportingManager] reportEventFor:reportingEvent];
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
