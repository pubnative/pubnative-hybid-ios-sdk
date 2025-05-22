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

- (void)addCompanion:(HyBidVASTCompanion *)companion
{
    if ([[companion staticResources] count] > 0) {
        for (HyBidVASTStaticResource *resource in [companion staticResources]) {
            if ([[resource content] length] > 0) {
                BOOL isAvailable = [self verifyImageAtURL:[resource content]];
                if (isAvailable) {
                    HyBidVASTEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_STATIC fromCompanion:companion withContent:[resource content]];
                    [self.endCardsStorage addObject:endCard];
                }
            }
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
}

- (BOOL)verifyImageAtURL:(NSString *)urlString {
    __block BOOL isAvailable = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        isAvailable = (data != nil && error == nil && ((NSHTTPURLResponse *)response).statusCode == 200 && [UIImage imageWithData:data]);
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return isAvailable;
}

- (HyBidVASTEndCard *)createEndCardWithType:(HyBidVASTEndCardType)type fromCompanion:(HyBidVASTCompanion *)companion withContent:(NSString *)content
{
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
