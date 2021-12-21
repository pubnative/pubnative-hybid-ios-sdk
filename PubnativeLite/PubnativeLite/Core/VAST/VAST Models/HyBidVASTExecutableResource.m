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

#import "HyBidVASTExecutableResource.h"
#import "HyBidVASTXMLParserHelper.h"

@interface HyBidVASTExecutableResource ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@property (nonatomic) int index;

@property (nonatomic, strong)HyBidVASTXMLParserHelper *parserHelper;

@end

@implementation HyBidVASTExecutableResource

- (instancetype)initWithDocumentArray:(NSArray *)array atIndex: (int)index
{
    if (self) {
        self.vastDocumentArray = [array mutableCopy];
        self.index = index;
        self.parserHelper = [[HyBidVASTXMLParserHelper alloc] initWithDocumentArray:array];
    }
    return self;
}

- (NSString *)language
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//ExecutableResource"];
    return [self.parserHelper getContentForAttribute:@"language" inNode: array[self.index]];
}

- (NSString *)apiFramework
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//ExecutableResource"];
    return [self.parserHelper getContentForAttribute:@"apiFramework" inNode: array[self.index]];
}

- (NSString *)url
{
    NSArray *array = [self.parserHelper getArrayResultsForQuery:@"//ExecutableResource"];
    return [self.parserHelper getContentForNode:array[self.index]];
}

@end
