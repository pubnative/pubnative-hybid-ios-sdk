// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

#if !defined(NSNullIfEmpty)
    #define NSNullIfEmpty(A)  ({ __typeof__(A) __a = (A); __a ? __a : [NSNull null]; })
#endif

#if !defined(NSNullIfDictionaryEmpty)
    #define NSNullIfDictionaryEmpty(A)  ({ __typeof__(A) __a = (A); __a.count > 0 ? __a : [NSNull null]; })
#endif

@interface HyBidVGIMacros : NSObject

@end
