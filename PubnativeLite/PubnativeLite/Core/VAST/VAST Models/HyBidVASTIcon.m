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

#import "HyBidVASTIcon.h"
#import "HyBidVASTXMLParserHelper.h"

@interface HyBidVASTIcon ()

@property (nonatomic, strong) NSMutableArray *vastDocumentArray;
@property (nonatomic) int index;
@property (nonatomic, strong)HyBidVASTXMLParserHelper *parserHelper;

@end

@implementation HyBidVASTIcon

- (instancetype)initWithDocumentArray:(NSArray *)array atIndex: (int)index
{
    self = [super init];
    if (self) {
        self.vastDocumentArray = [array mutableCopy];
        self.index = index;
        self.parserHelper = [[HyBidVASTXMLParserHelper alloc] initWithDocumentArray:array];
    }
    return self;
}


- (NSString *)apiFramework
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"apiFramework" inNode: array[self.index]];
}

- (NSString *)duration
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"duration" inNode: array[self.index]];
}

- (NSString *)height
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"height" inNode: array[self.index]];
}

- (NSString *)width
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"width" inNode: array[self.index]];
}

- (NSArray<NSString *> *)iconViewTracking
{
    NSString *query = @"//Icons/Icon/IconViewTracking";
    NSArray *result = [self.parserHelper getArrayResultsForQuery:query];
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *node in result) {
        NSString *str = [self.parserHelper getContentForNode:node];
        [array addObject:str];
    }
    
    return array;
}

- (NSString *)offset
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"offset" inNode: array[self.index]];
}

- (NSString *)program
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"program" inNode: array[self.index]];
}

- (NSString *)pxRatio
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"pxratio" inNode: array[self.index]];
}

- (NSString *)xPosition
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"xPosition" inNode: array[self.index]];
}

- (NSString *)yPosition
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon"];
    return [self.parserHelper getContentForAttribute:@"yPosition" inNode: array[self.index]];
}

- (NSString *)staticResource
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon/StaticResource"];
    return [array count] > self.index ? [self.parserHelper getContentForNode:array[self.index]] : nil;
}

- (NSString *)iconClickThrough
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//Icons/Icon/IconClicks/IconClickThrough"];
    return [array count] > self.index ? [self.parserHelper getContentForNode:array[self.index]] : nil;
}

@end
