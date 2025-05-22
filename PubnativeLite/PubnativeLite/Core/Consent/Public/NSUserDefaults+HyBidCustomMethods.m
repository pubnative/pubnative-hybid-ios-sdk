// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "NSUserDefaults+HyBidCustomMethods.h"
#import "HyBidUserDataManager.h"
#import "objc/runtime.h"

@implementation NSUserDefaults (HyBidUserDefaultsCustomMethods)

+ (void)load {
    [super load];
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        SEL removePersistentDomainForNameSelector = @selector(removePersistentDomainForName:);
        SEL hyBidFixingObserversOnRemovePersistentDomainForNameSelector = @selector(hyBidFixingObserversOnRemovePersistentDomainForName:);
        Method originalMethod = class_getInstanceMethod(self, removePersistentDomainForNameSelector);
        Method extendedMethod = class_getInstanceMethod(self, hyBidFixingObserversOnRemovePersistentDomainForNameSelector);
        method_exchangeImplementations(originalMethod, extendedMethod);
    });
}

- (void)hyBidFixingObserversOnRemovePersistentDomainForName:domainName {
    NSDictionary *hyBidObservers = [self hyBidUserDefaultsHasObservers];
    [self hyBidRemoveObserversWithDictionary:hyBidObservers];
    [self hyBidFixingObserversOnRemovePersistentDomainForName:domainName];
    [self hyBidAddObserversWithDictionary:hyBidObservers];
}

- (NSDictionary*)hyBidUserDefaultsHasObservers {
    id observationInfo = (__bridge id) NSUserDefaults.standardUserDefaults.observationInfo;
    NSArray *observances = [observationInfo valueForKey: @"_observances"];
    NSArray<NSString *> *observersKeyPaths = [HyBidUserDataManager.sharedInstance keyPathsForGDPRObservers];
    NSMutableDictionary<NSString*, NSNumber*> *observersValues = [[NSMutableDictionary alloc] init];
    if (observances.count > 0) {
        for (id observance in observances) {
            
            id observer = [observance valueForKey:@"_observer"];
            if ([observer isMemberOfClass: [HyBidUserDataManager class]]) {

                id property = [observance valueForKey:@"_property"];
                NSString *keyPath = [property valueForKey:@"_keyPath"];
                
                BOOL isObserverAdded = [observersKeyPaths containsObject: keyPath];
                [observersValues setObject:[NSNumber numberWithBool:isObserverAdded] forKey:keyPath];
            }
        }
    }
    
    return [observersValues copy];
}

- (void)hyBidAddObserversWithDictionary:(NSDictionary*)keyPaths {
    for (id keyPath in keyPaths) {
        NSString *keyPathStringValue = (NSString*)keyPath;
        if ([[keyPaths objectForKey:keyPathStringValue] boolValue]) {
            [[NSUserDefaults standardUserDefaults] addObserver:HyBidUserDataManager.sharedInstance
                                                    forKeyPath:keyPathStringValue options:NSKeyValueObservingOptionNew
                                                       context:NULL];
        }
    }
}

- (void)hyBidRemoveObserversWithDictionary:(NSDictionary*)keyPaths {
    for (id keyPath in keyPaths) {
        NSString *keyPathStringValue = (NSString*)keyPath;
        if ([[keyPaths objectForKey:keyPathStringValue] boolValue]) {
            [[NSUserDefaults standardUserDefaults] removeObserver:HyBidUserDataManager.sharedInstance forKeyPath:keyPathStringValue];
        }
    }
}

@end
