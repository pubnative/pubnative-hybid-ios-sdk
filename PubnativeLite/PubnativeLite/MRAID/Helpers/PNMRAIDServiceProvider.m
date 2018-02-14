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

#import "PNMRAIDServiceProvider.h"
#import "PNBrowser.h"
#import <EventKit/EventKit.h>

@implementation PNMRAIDServiceProvider

- (void)openBrowser:(NSString *)urlString
{
    PNBrowser *browser = [[PNBrowser alloc] initWithDelegate:nil withFeatures:@[kPubnativeBrowserFeatureSupportInlineMediaPlayback
                                                                                , kPubnativeBrowserFeatureDisableStatusBar
                                                                                , kPubnativeBrowserFeatureScalePagesToFit]];
    [browser loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)playVideo:(NSString *)urlString
{
    NSURL *videoUrl = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:videoUrl];
}

- (void)storePicture:(NSString *)urlString
{
    [self downloadImageWithURL:[NSURL URLWithString:urlString] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }];
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else {
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)createEvent:(NSString *)eventJSON
{
    NSData *data = [eventJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];

    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mmZZZZZ"];
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = [jsonResponse objectForKey:@"description"];
        event.location = [jsonResponse objectForKey:@"location"];
        if ([jsonResponse objectForKey:@"start"]) {
            if ([jsonResponse objectForKey:@"end"]) {
                event.startDate = [dateFormatter dateFromString:[jsonResponse objectForKey:@"start"]];
                event.endDate = [dateFormatter dateFromString:[jsonResponse objectForKey:@"end"]];
            } else {
                event.startDate = [dateFormatter dateFromString:[jsonResponse objectForKey:@"start"]];
                event.endDate = [dateFormatter dateFromString:[jsonResponse objectForKey:@"start"]];
                event.allDay = TRUE;
            }
        } else {
            return;
        }
        event.calendar = [store defaultCalendarForNewEvents];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    }];
    
}

- (void)sendSMS:(NSString *)urlString
{
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:[@"sms:" stringByAppendingString:urlString]]];
}

- (void)callNumber:(NSString *)urlString
{
    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:urlString]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:urlString]];
    
    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
        [UIApplication.sharedApplication openURL:phoneUrl];
    } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
    } else {
        // Show an error message: Your device can not do phone calls.
    }
}
@end
