// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

#define HYBID_AD_FEEDBACK_MACRO_APP_TOKEN @"${APPTOKEN}"

@interface HyBidAdFeedbackMacroUtil : NSObject

+ (NSString*)formatUrl:(NSString*)feedbackUrl withZoneID:(NSString *)zoneID;

@end
