// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTMediaFilePicker.h"
#import "PNLiteReachability.h"
#import <UIKit/UIKit.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidVASTMediaFilePicker()

+ (BOOL)isMIMETypeCompatible:(HyBidVASTMediaFile *)vastMediaFile;

@end

@implementation HyBidVASTMediaFilePicker

+ (HyBidVASTMediaFile *)pick:(NSArray *)mediaFiles {
    // Check whether we even have a network connection.
    // If not, return a nil.
    if (![HyBidVASTMediaFilePicker isInternetReachable]) {
        return nil;
    }
    
    // Go through the provided media files and only those that have a compatible MIME type.
    NSMutableArray *compatibleMediaFiles = [[NSMutableArray alloc] init];
    for (HyBidVASTMediaFile *vastMediaFile in mediaFiles) {
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
        HyBidVASTMediaFile *mf1 = (HyBidVASTMediaFile *)a;
        HyBidVASTMediaFile *mf2 = (HyBidVASTMediaFile *)b;
        int area1 = [mf1.width intValue] * [mf1.height intValue];
        int area2 = [mf2.width intValue] * [mf2.height intValue];
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
        int videoArea = [((HyBidVASTMediaFile *)sortedMediaFiles[i]).width intValue] * [((HyBidVASTMediaFile *)sortedMediaFiles[i]).height intValue];
        int diff = abs(screenArea - videoArea);
       if (diff >= bestMatchDiff) {
            break;
        }
        bestMatch = i;
        bestMatchDiff = diff;
    }
    
    HyBidVASTMediaFile *toReturn = (HyBidVASTMediaFile *)sortedMediaFiles[bestMatch];
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

+ (BOOL)isMIMETypeCompatible:(HyBidVASTMediaFile *)vastMediaFile {
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
