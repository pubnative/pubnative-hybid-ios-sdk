//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidVASTImpressions.h"
#import "HyBidVASTXMLParserHelper.h"

@interface HyBidVASTImpressions ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@property (nonatomic, strong)HyBidVASTXMLParserHelper *parserHelper;

@end

@implementation HyBidVASTImpressions

- (instancetype)initWithDocumentArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.vastDocumentArray = [array mutableCopy];
        self.parserHelper = [[HyBidVASTXMLParserHelper alloc] initWithDocumentArray:array];
    }
    return self;
}

- (NSArray<HyBidVASTImpression *> *)impressions
{
    NSString *query = @"/VAST/Ad/InLine/Impression";
    NSArray *result = [self.parserHelper getArrayResultsForQuery:query];
    NSMutableArray<HyBidVASTImpression *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTImpression *impression = [[HyBidVASTImpression alloc] initWithDocumentArray:self.vastDocumentArray atIndex:i];
        [array addObject:impression];
    }
    
    return array;
}

@end
