//
//  Copyright © 2020 PubNative. All rights reserved.
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
                   completion:^(HyBidVASTModel *model, HyBidVASTParserError error) {
       if (!model) {
           NSError *parseError = [NSError hyBidParseError];
           
           switch(error) {
               case 0: // HyBidVASTParserError_None
                   parseError = [NSError hyBidUnknownError];
                   break;
               case 1: // HyBidVASTParserError_XMLParse
                   parseError = [NSError hyBidParseError];
                   break;
               case 2: // HyBidVASTParserError_SchemaValidation
                   parseError = [NSError hyBidVASTParserSchemaValidationError];
                   break;
               case 3: // HyBidVASTParserError_TooManyWrappers
                   parseError = [NSError hyBidVASTParserTooManyWrappersError];
                   break;
               case 4: // HyBidVASTParserError_NoCompatibleMediaFile
                   parseError = [NSError hyBidVASTParserNoCompatibleMediaFileError];
                   break;
               case 5: // HyBidVASTParserError_NoInternetConnection
                   parseError = [NSError hyBidVASTParserNoInternetConnectionError];
                   break;
               case 6: // HyBidVASTParserError_MovieTooShort
                   parseError = [NSError hyBidVASTParserMovieTooShortError];
                   break;
               case 7: // HyBidVASTParserError_BothAdAndErrorPresentInRootResponse
                   parseError = [NSError hyBidVASTBothAdAndErrorPresentInRootResponse];
                   break;
               case 8: // HyBidVASTParserError_NoAdResponse:
                   parseError = [NSError hyBidVASTNoAdResponse];
                   break;
           }
           
           block(nil, parseError);
       } else {
           block(model, nil);
       }
   }];
}

@end
