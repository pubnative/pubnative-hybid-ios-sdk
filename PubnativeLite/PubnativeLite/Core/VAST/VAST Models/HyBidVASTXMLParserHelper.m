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

#import "HyBidVASTXMLParserHelper.h"
#import "PNLiteVASTXMLUtil.h"

@interface HyBidVASTXMLParserHelper ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@end

@implementation HyBidVASTXMLParserHelper

- (instancetype)initWithDocumentArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.vastDocumentArray = [array mutableCopy];
    }
    return self;
}

- (NSString *)getContentForAttribute:(NSString *)attr inNode:(NSDictionary *)node {
    NSArray *nodeAttributeArray = node[@"nodeAttributeArray"];
    if ([nodeAttributeArray count] > 0) {
        // return the first array element that is not a comment
        for (NSDictionary *childNode in nodeAttributeArray) {
            if ([childNode[@"attributeName"] isEqualToString:attr]) {
                return childNode[@"nodeContent"];
            }
        }
    }
    
    return nil;
}

- (NSString *)getContentForQuery:(NSString *)query
{
    // sanity check
    
    if (self.vastDocumentArray == nil || [self.vastDocumentArray count] == 0) {
        return nil;
    }
    
    NSString *xmlValue;
    NSArray *results = performXMLXPathQuery(self.vastDocumentArray[0], query);
    // there should be only a single result
    if ([results count] > 0) {
        NSDictionary *attribute = results[0];
        xmlValue = attribute[@"nodeContent"];
    }
    return [xmlValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)getContentForNode:(NSDictionary *)node {
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }

    NSArray *childArray = node[@"nodeChildArray"];
    if ([childArray count] > 0) {
        // return the first array element that is not a comment
        for (NSDictionary *childNode in childArray) {
            if ([childNode[@"nodeName"] isEqualToString:@"comment"]) {
                continue;
            }
            return childNode[@"nodeContent"];
        }
    }

    return nil;
}

- (NSArray *)getArrayResultsForQuery:(NSString *)query {
    // sanity check
    
    if (self.vastDocumentArray == nil || [self.vastDocumentArray count] == 0) {
        return nil;
    }
    
    NSString *xmlString = [[NSString alloc] initWithData:self.vastDocumentArray[0] encoding:NSUTF8StringEncoding];
    
    // having XML namespace in the XML causes parsing issues
    // therefore we are replacing `xmlns` with `hybid`
    NSString *newXmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns=" withString:@"hybid="];
    NSData *newXmlData = [newXmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    return performXMLXPathQuery(newXmlData, query);
}

@end
