// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface Quote : NSObject

@property (nonatomic, strong) NSString* quoteText;
@property (nonatomic, strong) NSString* quoteAuthor;

- (id)initWithText:(NSString*)text andAuthor:(NSString*)author;

@end
