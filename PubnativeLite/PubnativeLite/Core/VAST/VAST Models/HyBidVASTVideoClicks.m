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

#import "HyBidVASTVideoClicks.h"
#import "HyBidVASTXMLParserHelper.h"

@interface HyBidVASTVideoClicks ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@property (nonatomic, strong)HyBidVASTXMLParserHelper *parserHelper;

@end

@implementation HyBidVASTVideoClicks

- (instancetype)initWithDocumentArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.vastDocumentArray = [array mutableCopy];
        self.parserHelper = [[HyBidVASTXMLParserHelper alloc] initWithDocumentArray:array];
    }
    return self;
}

- (NSArray<HyBidVASTVideoClick *> *)allClicks
{
    NSMutableArray<HyBidVASTVideoClick *> *array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:[self trackingClicks]];
    [array addObjectsFromArray:[self throughClicks]];
    [array addObjectsFromArray:[self customClicks]];
    
    return array;
}

- (NSArray<HyBidVASTVideoClick *> *)trackingClicks
{
    NSMutableArray<HyBidVASTVideoClick *> *array = [[NSMutableArray alloc] init];
    NSString *clickTrackingQuery = @"//ClickTracking";
    NSArray *clickTrackingResult = [self.parserHelper getArrayResultsForQuery: clickTrackingQuery];
    
    for (int i = 0; i < [clickTrackingResult count]; i++) {
        HyBidVASTVideoClick *click = [[HyBidVASTVideoClick alloc] initWithNode:clickTrackingResult[i] andWithType:@"ClickTracking"];
        [array addObject:click];
    }
    
    return array;
}

- (NSArray<HyBidVASTVideoClick *> *)throughClicks
{
    NSMutableArray<HyBidVASTVideoClick *> *array = [[NSMutableArray alloc] init];
    NSString *clickThroughQuery = @"//ClickThrough";
    NSArray *clickThroughResult = [self.parserHelper getArrayResultsForQuery: clickThroughQuery];
    
    for (int i = 0; i < [clickThroughResult count]; i++) {
        HyBidVASTVideoClick *click = [[HyBidVASTVideoClick alloc] initWithNode:clickThroughResult[i] andWithType:@"ClickThrough"];
        [array addObject:click];
    }
    
    return array;
}

- (NSArray<HyBidVASTVideoClick *> *)customClicks
{
    NSMutableArray<HyBidVASTVideoClick *> *array = [[NSMutableArray alloc] init];
    NSString *clickCustomQuery = @"//CustomClick";
    NSArray *clickCustomResult = [self.parserHelper getArrayResultsForQuery: clickCustomQuery];
    
    for (int i = 0; i < [clickCustomResult count]; i++) {
        HyBidVASTVideoClick *click = [[HyBidVASTVideoClick alloc] initWithNode:clickCustomResult[i] andWithType:@"CustomClick"];
        [array addObject:click];
    }
    
    return array;
}

@end
