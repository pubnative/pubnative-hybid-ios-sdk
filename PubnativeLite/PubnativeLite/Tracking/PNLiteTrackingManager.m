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
#import "PNLiteTrackingManager.h"
#import "PNLiteTrackingManagerItem.h"
#import "PNLiteHttpRequest.h"
#import "HyBidLogger.h"

NSString * const PNLiteTrackingManagerQueueKey             = @"PNLiteTrackingManager.queue.key";
NSString * const PNLiteTrackingManagerFailedQueueKey       = @"PNLiteTrackingManager.failedQueue.key";
NSTimeInterval const PNLiteTrackingManagerItemValidTime    = 1800;

@interface PNLiteTrackingManager () <PNLiteHttpRequestDelegate>

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) PNLiteTrackingManagerItem *currentItem;

@end

@implementation PNLiteTrackingManager

- (void)dealloc {
    self.currentItem = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isRunning = NO;
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

+ (void)trackWithURL:(NSURL*)url {
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
        }
    }
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
