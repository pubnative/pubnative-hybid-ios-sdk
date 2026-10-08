//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidJSBeaconLoader+Testing.h"
#import <objc/runtime.h>

static IMP hyBidOriginalLoadBeaconIMP = NULL;

@implementation HyBidJSBeaconLoader (Testing)

+ (void)hybid_stubLoadWithError:(NSError *)error {
    Method method = class_getClassMethod(self, @selector(loadBeacon:completion:));
    IMP stub = imp_implementationWithBlock(^(id _self, NSString *payload, void (^completion)(NSError * _Nullable)) {
        completion(error);
    });
    IMP previous = method_setImplementation(method, stub);
    if (!hyBidOriginalLoadBeaconIMP) {
        hyBidOriginalLoadBeaconIMP = previous;
    }
}

+ (void)hybid_removeLoadStub {
    if (!hyBidOriginalLoadBeaconIMP) { return; }
    Method method = class_getClassMethod(self, @selector(loadBeacon:completion:));
    method_setImplementation(method, hyBidOriginalLoadBeaconIMP);
    hyBidOriginalLoadBeaconIMP = NULL;
}

@end
