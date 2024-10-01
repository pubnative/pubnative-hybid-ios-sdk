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
