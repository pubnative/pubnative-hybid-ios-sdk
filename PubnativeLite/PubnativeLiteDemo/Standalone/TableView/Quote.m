// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "Quote.h"

@implementation Quote

- (id)initWithText:(NSString*)text andAuthor:(NSString*)author {
    self = [super init];
    if (self) {
        self.quoteAuthor = author;
        self.quoteText = text;
    }
    return self;
}

@end
