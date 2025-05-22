// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
#import "PNLiteTrackingManager.h"
#import "PNLiteTrackingManagerItem.h"
#import "PNLiteHttpRequest.h"
#import "ATOMError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

NSString * const PNLiteTrackingManagerQueueKey             = @"PNLiteTrackingManager.queue.key";
NSString * const PNLiteTrackingManagerFailedQueueKey       = @"PNLiteTrackingManager.failedQueue.key";
NSTimeInterval const PNLiteTrackingManagerItemValidTime    = 1800;

@interface PNLiteTrackingManager () <PNLiteHttpRequestDelegate>

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) PNLiteTrackingManagerItem *currentItem;

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSArray<NSString *>*> *trackedURLsDictionary;

@end

@implementation PNLiteTrackingManager

- (void)dealloc {
    self.currentItem = nil;
    self.ad = nil;
    self.trackedURLsDictionary = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isRunning = NO;
        self.trackedURLsDictionary = [NSMutableDictionary new];
    }
    return self;
}

+ (instancetype)sharedManager {
    static PNLiteTrackingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PNLiteTrackingManager alloc] init];
    });
    return instance;
}

+ (void)trackWithURL:(NSURL*)url withType:(NSString *)type forAd:(HyBidAd *)ad {
    [[self sharedManager] setAd:ad];
    
    if (!url) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"URL passed is nil or empty, dropping this call."];
    } else {
        // Enqueue failed items
        NSMutableArray *failedQueue = [self queueForKey:PNLiteTrackingManagerFailedQueueKey];
        for (NSDictionary *dictionary in failedQueue) {
            PNLiteTrackingManagerItem *item = [[PNLiteTrackingManagerItem alloc] initWithDictionary:dictionary];
            [self enqueueItem:item withQueueKey:PNLiteTrackingManagerQueueKey];
        }
        [self setQueue:nil forKey:PNLiteTrackingManagerFailedQueueKey];
        
        // Enqueue current item
        PNLiteTrackingManagerItem *item = [[PNLiteTrackingManagerItem alloc] init];
        item.url = url;
        item.type = type;
        item.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [self enqueueItem:item withQueueKey:PNLiteTrackingManagerQueueKey];
        [[self sharedManager] trackNextItem];
    }
}

- (void)trackNextItem {
    if(!self.isRunning) {
        self.isRunning = YES;
        
        PNLiteTrackingManagerItem *item = [PNLiteTrackingManager dequeueItemWithQueueKey:PNLiteTrackingManagerQueueKey];
        if(item) {
            self.currentItem = item;
            NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval itemTimestamp = [item.timestamp doubleValue];
            if((currentTimestamp - itemTimestamp) < PNLiteTrackingManagerItemValidTime) {
                // Track item
                [[PNLiteHttpRequest alloc] startWithUrlString:[self.currentItem.url absoluteString] withMethod:@"GET" delegate:self];
                
                [self collectTrackedURLs:[self.currentItem.url absoluteString] withType:self.currentItem.type];
            } else {
                // Discard the item and continue
//                This code piece down below makes sure that isRunning param resets itself.
//                But this scenario is happening only when we have breakpoints.
//                Since Timestamp difference is not a valid time because we are debugging and we are using time for it.
//                self.isRunning = NO;
                [self trackNextItem];
            }
        } else {
            self.isRunning = NO;
            
            [self sendTrackedUrlsToAtomIfNeeded];
        }
    }
}

- (void)collectTrackedURLs:(NSString *)url withType:(NSString *)type
{
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray:self.trackedURLsDictionary[type]];
    [array addObject:url];
    
    self.trackedURLsDictionary[type] = array;
}

- (void)sendTrackedUrlsToAtomIfNeeded
{
    #if __has_include(<ATOM/ATOM-Swift.h>)
    NSString *creativeID = [self.ad creativeID];
    NSMutableArray<NSString *> *impressionURLs = [NSMutableArray new];
    NSMutableArray<NSString *> *clickURLs = [NSMutableArray new];

    for (NSString *key in self.trackedURLsDictionary.allKeys) {
        if ([key isEqualToString:@"impression"]) {
            [impressionURLs addObjectsFromArray:self.trackedURLsDictionary[key]];
        } else if ([key isEqualToString:@"click"]) {
            [clickURLs addObjectsFromArray:self.trackedURLsDictionary[key]];
        }
    }
    
    @try {
        Class ATOMAdParametersClass = NSClassFromString(@"ATOM.ATOMAdParameters");
        Class ATOM = NSClassFromString(@"ATOM.Atom");
        
        if (ATOMAdParametersClass == nil && ATOM != nil) {
            NSString *reason = [[NSString alloc] initWithFormat:@"ATOM Error: %d. The version of ATOM is incompatible with this HyBid. The functionality is limited. Please update to the newer version.", ATOMCannotFireImpressions];
            NSException* incompatibleException = [NSException
                    exceptionWithName:@"IncompatibleATOMVersionException"
                    reason: reason
                    userInfo:nil];
            @throw incompatibleException;
        }
        
        ATOMAdParameters *atomAdParameters = [[ATOMAdParameters alloc] initWithCreativeID:creativeID cohorts: [self.ad cohorts] impressionURLs:impressionURLs clickURL:clickURLs];
        [Atom impressionFiredWithAdParameters:atomAdParameters];
    }
    @catch (NSException *exception) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: exception.reason, NSStringFromSelector(_cmd)]];
    }
    
    [self.trackedURLsDictionary removeAllObjects];
    #endif
}

#pragma mark Queue

+ (void)enqueueItem:(PNLiteTrackingManagerItem *)item withQueueKey:(NSString*)key {
    if(item) {
        NSMutableArray *queue = [PNLiteTrackingManager queueForKey:key];
        [queue addObject:[item toDictionary]];
        [PNLiteTrackingManager setQueue:queue forKey:key];
    }
}

+ (PNLiteTrackingManagerItem *)dequeueItemWithQueueKey:(NSString*)key {
    PNLiteTrackingManagerItem *result = nil;
    NSMutableArray *queue = [PNLiteTrackingManager queueForKey:key];
    if (queue.count > 0) {
        result = [[PNLiteTrackingManagerItem alloc] initWithDictionary:queue[0]];
        [queue removeObjectAtIndex:0];
        [PNLiteTrackingManager setQueue:queue forKey:key];
    }
    return result;
}

+ (NSMutableArray*)queueForKey:(NSString*)key {
    NSArray *queue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSMutableArray *result;
    
    if(queue) {
        result = [queue mutableCopy];
    } else {
        result = [NSMutableArray array];
    }
    return result;
}

+ (void)setQueue:(NSArray*)queue forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setObject:queue
                                              forKey:key];
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    self.isRunning = NO;
    [self trackNextItem];
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Track Request %@ failed with error: %@",request, error.localizedDescription]];
    [PNLiteTrackingManager enqueueItem:self.currentItem withQueueKey:PNLiteTrackingManagerFailedQueueKey];
    self.isRunning = NO;
    [self trackNextItem];
}


@end
