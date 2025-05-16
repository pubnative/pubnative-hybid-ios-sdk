// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVideoAdProcessor.h"
#import "HyBidVASTParser.h"
#import "HyBidError.h"

@interface HyBidVideoAdProcessor()

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVideoAdProcessor

- (void)dealloc {
    self.parser = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.parser = [[HyBidVASTParser alloc] init];
    }
    return self;
}
- (void)processVASTString:(NSString *)vastString completion:(videoAdProcessorCompletionBlock)block {

   [self.parser parseWithData:[vastString dataUsingEncoding:NSUTF8StringEncoding]
                   completion:^(HyBidVASTModel *model, HyBidVASTParserError* error) {
       if (!model) {
           block(nil, error);
       } else {
           block(model, nil);
       }
   }];
}

@end
