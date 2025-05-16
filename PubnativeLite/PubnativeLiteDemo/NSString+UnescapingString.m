// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "NSString+UnescapingString.h"

@implementation NSString (UnescapingString)

- (NSString *)unescapeString:(NSString *)string {
    NSString *doubleQuoteRemovedString = [string stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    NSString *backslashRemovedString = [doubleQuoteRemovedString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    return backslashRemovedString;
}

@end
