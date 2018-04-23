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

#import "PNLiteBreadcrumb.h"
#import "PNLiteCrashTracker.h"
#import "BugsnagLogger.h"
#import "PNLiteKeys.h"

static NSString *const PNLiteBreadcrumbDefaultName = @"manual";
static NSUInteger const PNLiteBreadcrumbMaxByteSize = 4096;

NSString *PNLiteBreadcrumbTypeValue(PNLiteBreadcrumbType type) {
    switch (type) {
    case PNLiteBreadcrumbTypeLog:
        return @"log";
    case PNLiteBreadcrumbTypeUser:
        return @"user";
    case PNLiteBreadcrumbTypeError:
        return PNLiteKeyError;
    case PNLiteBreadcrumbTypeState:
        return @"state";
    case PNLiteBreadcrumbTypeManual:
        return @"manual";
    case PNLiteBreadcrumbTypeProcess:
        return @"process";
    case PNLiteBreadcrumbTypeRequest:
        return @"request";
    case PNLiteBreadcrumbTypeNavigation:
        return @"navigation";
    }
}

@interface PNLiteBreadcrumbs ()

@property(nonatomic, readwrite, strong) NSMutableArray *breadcrumbs;
@property(nonatomic, readonly, strong) dispatch_queue_t readWriteQueue;
@end

@interface PNLiteBreadcrumb ()

- (NSDictionary *_Nullable)objectValue;
@end

@implementation PNLiteBreadcrumb

- (instancetype)init {
    if (self = [super init]) {
        _timestamp = [NSDate date];
        _name = PNLiteBreadcrumbDefaultName;
        _type = PNLiteBreadcrumbTypeManual;
        _metadata = @{};
    }
    return self;
}

- (BOOL)isValid {
    return self.name.length > 0 && self.timestamp != nil;
}

- (NSDictionary *)objectValue {
    @synchronized (self) {
        NSString *timestamp =
        [[PNLiteCrashTracker payloadDateFormatter] stringFromDate:_timestamp];
        if (timestamp && _name.length > 0) {
            NSMutableDictionary *metadata = [NSMutableDictionary new];
            for (NSString *key in _metadata) {
                metadata[[key copy]] = [_metadata[key] copy];
            }
            return @{
                 PNLiteKeyName : [_name copy],
                 PNLiteKeyTimestamp : timestamp,
                 PNLiteKeyType : PNLiteBreadcrumbTypeValue(_type),
                 PNLiteKeyMetaData : metadata
            };
        }
        return nil;
    }
}

@synthesize timestamp = _timestamp;

- (NSDate *)timestamp {
    @synchronized (self) {
        return _timestamp;
    }
}

- (void)setTimestamp:(NSDate * _Nullable)timestamp {
    @synchronized (self) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(timestamp))];
        _timestamp = timestamp;
        [self didChangeValueForKey:NSStringFromSelector(@selector(timestamp))];
    }
}

@synthesize name = _name;

- (NSString *)name {
    @synchronized (self) {
        return _name;
    }
}

@synthesize type = _type;

- (PNLiteBreadcrumbType)type {
    @synchronized (self) {
        return _type;
    }
}

- (void)setType:(PNLiteBreadcrumbType)type {
    @synchronized (self) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(type))];
        _type = type;
        [self didChangeValueForKey:NSStringFromSelector(@selector(type))];
    }
}

- (void)setName:(NSString *)name {
    @synchronized (self) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(name))];
        _name = name;
        [self didChangeValueForKey:NSStringFromSelector(@selector(name))];
    }
}

@synthesize metadata = _metadata;

- (NSDictionary *)metadata {
    @synchronized (self) {
        return _metadata;
    }
}

- (void)setMetadata:(NSDictionary *)metadata {
    @synchronized (self) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(metadata))];
        _metadata = metadata;
        [self didChangeValueForKey:NSStringFromSelector(@selector(metadata))];
    }
}

+ (instancetype)breadcrumbWithBlock:(PNLiteBreadcrumbConfiguration)block {
    PNLiteBreadcrumb *crumb = [self new];
    if (block) {
        block(crumb);
    }
    if ([crumb isValid]) {
        return crumb;
    }
    return nil;
}

@end

@implementation PNLiteBreadcrumbs

NSUInteger PNLiteBreadcrumbsDefaultCapacity = 20;

- (instancetype)init {
    if (self = [super init]) {
        _breadcrumbs = [NSMutableArray new];
        _capacity = PNLiteBreadcrumbsDefaultCapacity;
        _readWriteQueue = dispatch_queue_create("com.bugsnag.BreadcrumbRead",
                                                DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)addBreadcrumb:(NSString *)breadcrumbMessage {
    [self addBreadcrumbWithBlock:^(PNLiteBreadcrumb *_Nonnull crumb) {
      crumb.metadata = @{PNLiteKeyMessage : breadcrumbMessage};
    }];
}

- (void)addBreadcrumbWithBlock:
    (void (^_Nonnull)(PNLiteBreadcrumb *_Nonnull))block {
    if (self.capacity == 0) {
        return;
    }
    PNLiteBreadcrumb *crumb = [PNLiteBreadcrumb breadcrumbWithBlock:block];
    if (crumb) {
        [self resizeToFitCapacity:self.capacity - 1];
        dispatch_barrier_sync(self.readWriteQueue, ^{
          [self.breadcrumbs addObject:crumb];
        });
    }
}
@synthesize capacity = _capacity;

- (NSUInteger)capacity {
    @synchronized (self) {
        return _capacity;
    }
}

- (void)setCapacity:(NSUInteger)capacity {
    @synchronized (self) {
        if (capacity == _capacity) {
            return;
        }
        [self resizeToFitCapacity:capacity];
        [self willChangeValueForKey:NSStringFromSelector(@selector(capacity))];
        _capacity = capacity;
        [self didChangeValueForKey:NSStringFromSelector(@selector(capacity))];
    }
}

- (void)clearBreadcrumbs {
    dispatch_barrier_sync(self.readWriteQueue, ^{
      [self.breadcrumbs removeAllObjects];
    });
}

- (NSUInteger)count {
    return self.breadcrumbs.count;
}

- (PNLiteBreadcrumb *)objectAtIndexedSubscript:(NSUInteger)index {
    if (index < [self count]) {
        __block PNLiteBreadcrumb *crumb = nil;
        dispatch_barrier_sync(self.readWriteQueue, ^{
          crumb = self.breadcrumbs[index];
        });
        return crumb;
    }
    return nil;
}

- (NSArray *)arrayValue {
    if ([self count] == 0) {
        return nil;
    }
    __block NSMutableArray *contents =
        [[NSMutableArray alloc] initWithCapacity:[self count]];
    dispatch_barrier_sync(self.readWriteQueue, ^{
      for (PNLiteBreadcrumb *crumb in self.breadcrumbs) {
          NSDictionary *objectValue = [crumb objectValue];
          NSError *error = nil;
          @try {
              if (![NSJSONSerialization isValidJSONObject:objectValue]) {
                  bsg_log_err(@"Unable to serialize breadcrumb: Not a valid "
                              @"JSON object");
                  continue;
              }
              NSData *data = [NSJSONSerialization dataWithJSONObject:objectValue
                                                             options:0
                                                               error:&error];
              if (data.length <= PNLiteBreadcrumbMaxByteSize)
                  [contents addObject:objectValue];
              else
                  bsg_log_warn(
                      @"Dropping breadcrumb (%@) exceeding %lu byte size limit",
                      crumb.name, (unsigned long)PNLiteBreadcrumbMaxByteSize);
          } @catch (NSException *exception) {
              bsg_log_err(@"Unable to serialize breadcrumb: %@", error);
          }
      }
    });
    return contents;
}

- (void)resizeToFitCapacity:(NSUInteger)capacity {
    if (capacity == 0) {
        [self clearBreadcrumbs];
    } else if ([self count] > capacity) {
        dispatch_barrier_sync(self.readWriteQueue, ^{
          [self.breadcrumbs
              removeObjectsInRange:NSMakeRange(0, self.count - capacity)];
        });
    }
}

@end
