// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTEndCardManager.h"
#import <UIKit/UIKit.h>

@interface HyBidVASTEndCardManager ()

@property (nonatomic, strong) NSMutableArray<HyBidVASTEndCard *> *endCardsStorage;

@end

@implementation HyBidVASTEndCardManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.endCardsStorage = [NSMutableArray new];
    }
    return self;
}

- (void)addCompanion:(HyBidVASTCompanion *)companion completion:(void(^)(void))completion {
    dispatch_group_t group = dispatch_group_create();

    if ([[companion staticResources] count] > 0) {
        for (HyBidVASTStaticResource *resource in [companion staticResources]) {
            NSString *content = [[resource content] copy];
            if (content.length == 0) continue;

            NSString *clickThrough = [[[companion companionClickThrough] content] copy];
            NSArray *clickTrackingsRaw = [companion companionClickTracking];
            HyBidVASTTrackingEvents *events = [companion trackingEvents];
            NSMutableArray<NSString *> *clickTrackings = [NSMutableArray new];
            for (HyBidVASTCompanionClickTracking *event in clickTrackingsRaw) {
                [clickTrackings addObject:[[event content] copy]];
            }

            dispatch_group_enter(group);
            [self verifyImageAtURL:content completion:^(BOOL isAvailable) {
                if (isAvailable) {
                    HyBidVASTEndCard *endCard = [[HyBidVASTEndCard alloc] init];
                    [endCard setType:HyBidEndCardType_STATIC];
                    [endCard setContent:content];
                    [endCard setClickThrough:clickThrough];
                    [endCard setClickTrackings:clickTrackings];
                    [endCard setEvents:events];
                    
                    [self.endCardsStorage addObject:endCard];
                }
                dispatch_group_leave(group);
            }];
        }
    }
    if ([[companion htmlResources] count] > 0) {
        for (HyBidVASTHTMLResource *resource in [companion htmlResources]) {
            if ([[resource content] length] > 0) {
                HyBidVASTEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_HTML fromCompanion:companion withContent:[resource content]];
                [self.endCardsStorage addObject:endCard];
            }
        }
    }
    if ([[companion iFrameResources] count] > 0) {
        for (HyBidVASTIFrameResource *resource in [companion iFrameResources]) {
            if ([[resource content] length] > 0) {
                HyBidVASTEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_IFRAME fromCompanion:companion withContent:[resource content]];
                [self.endCardsStorage addObject:endCard];
            }
        }
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}

- (void)verifyImageAtURL:(NSString *)urlString completion:(void(^)(BOOL isAvailable))completion {
    if (urlString.length == 0 || !completion) {
        if (completion) {
            completion(NO);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:5.0];

    void (^safeCompletion)(BOOL) = [completion copy];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL valid = NO;

        if (data && error == nil) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if (httpResp.statusCode == 200 && [UIImage imageWithData:data] != nil) {
                valid = YES;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (safeCompletion) {
                safeCompletion(valid);
            }
        });
    }];
    [task resume];
}

- (HyBidVASTEndCard *)createEndCardWithType:(HyBidVASTEndCardType)type fromCompanion:(HyBidVASTCompanion *)companion withContent:(NSString *)content {
    HyBidVASTEndCard *endCard = [[HyBidVASTEndCard alloc] init];
    [endCard setType:type];
    [endCard setContent:content];
    [endCard setClickThrough:[[companion companionClickThrough] content]];
    
    NSMutableArray<NSString *> *trackings = [NSMutableArray new];
    for (HyBidVASTCompanionClickTracking *event in [companion companionClickTracking]) {
        [trackings addObject:[event content]];
    }
    [endCard setClickTrackings:trackings];
    
    [endCard setEvents:[companion trackingEvents]];
    
    return endCard;
}

- (NSArray<HyBidVASTEndCard *> *)endCards {
    return self.endCardsStorage;
}

- (HyBidVASTCompanion *)pickBestCompanionFromCompanionAds:(HyBidVASTCompanionAds *)companionAds {
    if (!companionAds || [companionAds.companions count] == 0) {
        return nil;
    }

    NSArray<HyBidVASTCompanion *> *companions = [companionAds companions];
    
    NSArray<HyBidVASTCompanion *> *sortedCompanions = [companions sortedArrayUsingComparator:^NSComparisonResult(HyBidVASTCompanion *c1, HyBidVASTCompanion *c2) {
        int area1 = [c1.width intValue] * [c1.height intValue];
        int area2 = [c2.width intValue] * [c2.height intValue];
        if (area1 < area2) {
            return NSOrderedAscending;
        } else if (area1 > area2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int screenArea = screenSize.width * screenSize.height;

    int bestMatchIndex = 0;
    int bestMatchDiff = INT_MAX;

    for (int i = 0; i < sortedCompanions.count; i++) {
        HyBidVASTCompanion *companion = sortedCompanions[i];
        int companionArea = [companion.width intValue] * [companion.height intValue];
        int diff = abs(screenArea - companionArea);

        if (diff < bestMatchDiff) {
            bestMatchIndex = i;
            bestMatchDiff = diff;
        } else {
            break;
        }
    }

    return sortedCompanions[bestMatchIndex];
}

@end
