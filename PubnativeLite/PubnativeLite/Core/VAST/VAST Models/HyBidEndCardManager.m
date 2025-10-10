// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidEndCardManager.h"
#import <UIKit/UIKit.h>

@interface HyBidEndCardManager ()

@property (nonatomic, strong) NSMutableArray<HyBidEndCard *> *endCardsStorage;

@end

@implementation HyBidEndCardManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.endCardsStorage = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    self.endCardsStorage = nil;
}

- (void)addCompanion:(HyBidVASTCompanion *)companion completion:(void(^)(void))completion
{
    if (!companion) {
        if (completion) completion();
        return;
    }

    // Prepare common metadata
    NSString *clickThrough = [[[companion companionClickThrough] content] copy];
    HyBidVASTTrackingEvents *events = [companion trackingEvents];

    // Add HTML & iFrame end cards synchronously
    for (HyBidVASTHTMLResource *r in (companion.htmlResources ?: @[])) {
        if (r.content.length > 0) {
            HyBidEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_HTML
                                                      fromCompanion:companion
                                                       withContent:r.content];
            @synchronized (self.endCardsStorage) {
                [self.endCardsStorage addObject:endCard];
            }
        }
    }

    for (HyBidVASTIFrameResource *r in (companion.iFrameResources ?: @[])) {
        if (r.content.length > 0) {
            HyBidEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_IFRAME
                                                      fromCompanion:companion
                                                       withContent:r.content];
            @synchronized (self.endCardsStorage) {
                [self.endCardsStorage addObject:endCard];
            }
        }
    }

    // Collect static resources that actually need async verification
    NSArray<HyBidVASTStaticResource *> *statics = companion.staticResources ?: @[];
    NSMutableArray<HyBidVASTStaticResource *> *work = [NSMutableArray arrayWithCapacity:statics.count];
    for (HyBidVASTStaticResource *res in statics) {
        if (res.content.length > 0) { [work addObject:res]; }
    }

    // No async work? Finish immediately.
    if (work.count == 0) {
        if (completion) completion();
        return;
    }

    // Async verification for static images
    dispatch_group_t group = dispatch_group_create();

    for (HyBidVASTStaticResource *res in work) {
        NSString *content = [res.content copy];

        // Snapshot per-resource values
        NSArray *clickTrackingsRaw = companion.companionClickTracking ?: @[];
        NSMutableArray<NSString *> *clickTrackings = [NSMutableArray arrayWithCapacity:clickTrackingsRaw.count];
        for (HyBidVASTCompanionClickTracking *e in clickTrackingsRaw) {
            if (e.content.length > 0) { [clickTrackings addObject:[e.content copy]]; }
        }

        dispatch_group_enter(group);
        [self verifyImageAtURL:content completion:^(BOOL isAvailable) {
            if (isAvailable) {
                HyBidEndCard *endCard = [HyBidEndCard new];
                endCard.type = HyBidEndCardType_STATIC;
                endCard.content = content;
                endCard.clickThrough = clickThrough;
                endCard.clickTrackings = clickTrackings;
                endCard.events = events;

                @synchronized (self.endCardsStorage) {
                    [self.endCardsStorage addObject:endCard];
                }
            }
            dispatch_group_leave(group);
        }];
    }

    // Call completion when all verifications finish.
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) completion();
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

- (HyBidEndCard *)createEndCardWithType:(HyBidEndCardType)type fromCompanion:(HyBidVASTCompanion *)companion withContent:(NSString *)content {
    HyBidEndCard *endCard = [[HyBidEndCard alloc] init];
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

- (NSArray<HyBidEndCard *> *)endCards {
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

- (void)fetchEndCardsFromCreatives:(NSArray<HyBidVASTCreative *>*)creatives
                        completion:(void(^)(NSArray<HyBidEndCard *> * _Nullable endCards))completion {
    if (creatives.count == 0) {
        if (completion) completion(nil);
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    [self addCompanionsFromCreatives:creatives dispatchGroup:group];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        NSArray<HyBidEndCard *> *endCards = [weakSelf endCards];
        if (completion) {
            completion(endCards);
        }
    });
}

- (void)addCompanionsFromCreatives:(NSArray<HyBidVASTCreative *> *)creatives dispatchGroup:(dispatch_group_t)group {
    for (HyBidVASTCreative *creative in creatives) {
        HyBidVASTCompanionAds *companionAds = [creative companionAds];
        if (companionAds && [companionAds companions]) {
            for (HyBidVASTCompanion *companion in [companionAds companions]) {
                dispatch_group_enter(group);
                __weak typeof(self) weakSelf = self;
                if (weakSelf) {
                    [weakSelf addCompanion:companion completion:^{
                        dispatch_group_leave(group);
                    }];
                } else {
                    dispatch_group_leave(group);
                }
            }
        }
    }
}

@end
