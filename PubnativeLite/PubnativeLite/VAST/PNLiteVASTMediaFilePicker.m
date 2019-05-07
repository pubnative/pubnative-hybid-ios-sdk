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

#import "PNLiteVASTMediaFilePicker.h"
#import "PNLiteReachability.h"
#import <UIKit/UIKit.h>
#import "HyBidLogger.h"

@interface PNLiteVASTMediaFilePicker()

+ (BOOL)isMIMETypeCompatible:(PNLiteVASTMediaFile *)vastMediaFile;

@end

@implementation PNLiteVASTMediaFilePicker

+ (PNLiteVASTMediaFile *)pick:(NSArray *)mediaFiles {
    // Check whether we even have a network connection.
    // If not, return a nil.
    if (![PNLiteVASTMediaFilePicker isInternetReachable]) {
        return nil;
    }
    
    // Go through the provided media files and only those that have a compatible MIME type.
    NSMutableArray *compatibleMediaFiles = [[NSMutableArray alloc] init];
    for (PNLiteVASTMediaFile *vastMediaFile in mediaFiles) {
        // Make sure that you have type specified for mediafile and ignore accordingly
        if (vastMediaFile.type != nil && [self isMIMETypeCompatible:vastMediaFile]) {
            [compatibleMediaFiles addObject:vastMediaFile];
        }
    }
    if ([compatibleMediaFiles count] == 0) {
        return nil;
    }
    
    // Sort the media files based on their video size (in square pixels).
    NSArray *sortedMediaFiles = [compatibleMediaFiles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        PNLiteVASTMediaFile *mf1 = (PNLiteVASTMediaFile *)a;
        PNLiteVASTMediaFile *mf2 = (PNLiteVASTMediaFile *)b;
        int area1 = mf1.width * mf1.height;
        int area2 = mf2.width * mf2.height;
        if (area1 < area2) {
            return NSOrderedAscending;
        } else if (area1 > area2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    // Pick the media file with the video size closes to the device's screen size.
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int screenArea = screenSize.width * screenSize.height;
    int bestMatch = 0;
    int bestMatchDiff = INT_MAX;
    int len = (int)[sortedMediaFiles count];
    
    for (int i = 0; i < len; i++) {
        int videoArea = ((PNLiteVASTMediaFile *)sortedMediaFiles[i]).width * ((PNLiteVASTMediaFile *)sortedMediaFiles[i]).height;
        int diff = abs(screenArea - videoArea);
       if (diff >= bestMatchDiff) {
            break;
        }
        bestMatch = i;
        bestMatchDiff = diff;
    }
    
    PNLiteVASTMediaFile *toReturn = (PNLiteVASTMediaFile *)sortedMediaFiles[bestMatch];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Selected Media File: %@", toReturn.url]];
    return toReturn;
}

+ (BOOL)isInternetReachable {
    BOOL result = false;
    PNLiteReachability *reachability = [PNLiteReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    PNLiteNetworkStatus currentNetwork = [reachability currentReachabilityStatus];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"NetworkType: %ld", (long)currentNetwork]];
    result = currentNetwork != PNLiteNetworkStatus_NotReachable;
    [reachability stopNotifier];
    return result;}

+ (BOOL)isMIMETypeCompatible:(PNLiteVASTMediaFile *)vastMediaFile {
    NSString *pattern = @"(mp4|m4v|quicktime|3gpp)";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:vastMediaFile.type
                                      options:0
                                        range:NSMakeRange(0, [vastMediaFile.type length])];
    
    return ([matches count] > 0);
}

@end
