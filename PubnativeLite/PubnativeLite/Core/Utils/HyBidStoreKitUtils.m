// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidStoreKitUtils.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidStoreKitUtils

+ (NSMutableDictionary *)insertFidelitiesIntoDictionaryIfNeeded:(NSMutableDictionary *)dictionary
{
    id version = dictionary[SKStoreProductParameterAdNetworkVersion];
    id fidelitiesValue = dictionary[HyBidSKAdNetworkParameter.fidelities];
    if (![[HyBidSettings sharedInstance] supportMultipleFidelities] ||
        ![version respondsToSelector:@selector(doubleValue)] ||
        [version doubleValue] < 2.2 ||
        ![fidelitiesValue isKindOfClass:[NSArray class]]) {
        return dictionary;
    }

    for (id value in (NSArray *)fidelitiesValue) {
        if (![value isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        NSDictionary *fidelity = value;
        NSNumber *fidelityType = fidelity[HyBidSKAdNetworkParameter.fidelity];
        NSString *timestampString = fidelity[HyBidSKAdNetworkParameter.timestamp];
        NSString *nonceString = fidelity[HyBidSKAdNetworkParameter.nonce];
        NSString *signature = fidelity[HyBidSKAdNetworkParameter.signature];
        if (![fidelityType isKindOfClass:[NSNumber class]] || fidelityType.intValue != 1 ||
            ![timestampString isKindOfClass:[NSString class]] ||
            ![nonceString isKindOfClass:[NSString class]] ||
            ![signature isKindOfClass:[NSString class]] || signature.length == 0) {
            continue;
        }

        NSNumber *timestamp = [self getNSNumberFromString:timestampString];
        NSUUID *nonce = [[NSUUID alloc] initWithUUIDString:nonceString];
        if (timestamp == nil || nonce == nil) {
            continue;
        }

        if (@available(iOS 11.3, *)) {
            [dictionary setObject:timestamp forKey:SKStoreProductParameterAdNetworkTimestamp];
            [dictionary setObject:nonce forKey:SKStoreProductParameterAdNetworkNonce];
        }

        if (@available(iOS 13.0, *)) {
            [dictionary setObject:signature forKey:SKStoreProductParameterAdNetworkAttributionSignature];
            [dictionary setObject:fidelityType.stringValue forKey:HyBidSKAdNetworkParameter.fidelityType];
        }

        dictionary[HyBidSKAdNetworkParameter.fidelities] = nil;
        break;
    }

    return dictionary;
}

+ (NSNumber *)getNSNumberFromString:(NSString *)string
{
    if (string == nil || string.length == 0) {
        return nil;
    }

    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
        return nil;
    }

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    NSNumber *number = [numberFormatter numberFromString:trimmed];
    return number;
}


+ (NSDictionary *)cleanUpProductParams:(NSDictionary *)productParams {
    NSMutableDictionary* cleanDictionary = [productParams mutableCopy];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.fidelities];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.fidelityType];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.autoClose];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.delay];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.dismissible];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.endcardDelay];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.position];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.present];
    [cleanDictionary removeObjectForKey:HyBidSKAdNetworkParameter.click];

    return cleanDictionary;
}

@end
