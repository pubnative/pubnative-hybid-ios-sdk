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
    double skanVersion = [dictionary[@"adNetworkPayloadVersion"] doubleValue];
    if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [dictionary[HyBidSKAdNetworkParameter.fidelities] count] > 0) {
        NSArray<NSData *> *fidelitiesDataArray = dictionary[HyBidSKAdNetworkParameter.fidelities];
        
        if ([fidelitiesDataArray count] > 0) {
            for (NSData *fidelity in fidelitiesDataArray) {
                SKANObject skanObject;
                [fidelity getBytes:&skanObject length:sizeof(skanObject)];
                
                if (skanObject.fidelity == 1) {
                    if (@available(iOS 11.3, *)) {
                        NSString *timestampString = [NSString stringWithUTF8String:skanObject.timestamp];
                        NSNumber *timestamp = [self getNSNumberFromString:timestampString];
                        if (timestamp != nil) {
                            [dictionary setObject:timestamp forKey:SKStoreProductParameterAdNetworkTimestamp];
                        }
                        
                        NSString *nonce = [NSString stringWithUTF8String:skanObject.nonce];
                        [dictionary setObject:[[NSUUID alloc] initWithUUIDString:nonce] forKey:SKStoreProductParameterAdNetworkNonce];
                    }
                    
                    if (@available(iOS 13.0, *)) {
                        if (skanObject.signature != nil) {
                            NSString *signature = [NSString stringWithUTF8String:skanObject.signature];
                            if (signature != nil) {
                                [dictionary setObject:signature forKey:SKStoreProductParameterAdNetworkAttributionSignature];
                            }
                        }
                        
                        NSString *fidelity = [NSString stringWithFormat:@"%d", skanObject.fidelity];
                        [dictionary setObject:fidelity forKey:HyBidSKAdNetworkParameter.fidelityType];
                    }
                    
                    dictionary[HyBidSKAdNetworkParameter.fidelities] = nil;
                    
                    break; // Currently we support only 1 fidelity for each kind
                }
            }
        }
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
