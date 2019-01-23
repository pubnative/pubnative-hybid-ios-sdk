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

NSString * const kPNLiteTrackingManagerQueueKey             = @"PNLiteTrackingManager.queue.key";
NSString * const kPNLiteTrackingManagerFailedQueueKey       = @"PNLiteTrackingManager.failedQueue.key";
NSTimeInterval const kPNLiteTrackingManagerItemValidTime    = 1800;

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
    if (url == nil) {
        NSLog(@"PNLiteTrackingManager - URL passed is nil or empty, dropping this call: %@", url);
    } else {
        // Enqueue failed items
        NSMutableArray *failedQueue = [self queueForKey:kPNLiteTrackingManagerFailedQueueKey];
        for (NSDictionary *dictionary in failedQueue) {
            PNLiteTrackingManagerItem *item = [[PNLiteTrackingManagerItem alloc] initWithDictionary:dictionary];
            [self enqueueItem:item withQueueKey:kPNLiteTrackingManagerQueueKey];
        }
        [self setQueue:nil forKey:kPNLiteTrackingManagerFailedQueueKey];
        
        // Enqueue current item
        PNLiteTrackingManagerItem *item = [[PNLiteTrackingManagerItem alloc] init];
        item.url = url;
        item.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [self enqueueItem:item withQueueKey:kPNLiteTrackingManagerQueueKey];
        [[self sharedManager] trackNextItem];
    }
}

- (void)trackNextItem {
    if(!self.isRunning) {
        
        self.isRunning = YES;
        PNLiteTrackingManagerItem *item = [PNLiteTrackingManager dequeueItemWithQueueKey:kPNLiteTrackingManagerQueueKey];
        if(item) {
            self.currentItem = item;
            NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval itemTimestamp = [item.timestamp doubleValue];
            if((currentTimestamp - itemTimestamp) < kPNLiteTrackingManagerItemValidTime) {
                // Track item
                [[PNLiteHttpRequest alloc] startWithUrlString:[self.currentItem.url absoluteString] withMethod:@"GET" delegate:self];
            } else {
                // Discard the item and continue
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
    [PNLiteTrackingManager enqueueItem:self.currentItem withQueueKey:kPNLiteTrackingManagerFailedQueueKey];
    self.isRunning = NO;
    [self trackNextItem];
}


@end
