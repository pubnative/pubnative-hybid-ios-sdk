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

#import "HyBidVASTModel.h"
#import "PNLiteVASTXMLUtil.h"
#import "HyBidLogger.h"

@interface HyBidVASTModel ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

// returns an array of VASTUrlWithId objects
- (NSArray *)resultsForQuery:(NSString *)query;

// returns the text content of both simple text and CDATA sections
- (NSString *)content:(NSDictionary *)node;

@end

@implementation HyBidVASTModel

- (NSString *)version
{
    NSString *query = @"/VAST/@version";
    return [self getXMLValueFromQuery:query];
}

- (NSArray<HyBidVASTAd *> *)ads
{
    NSString *query = @"//Ad";
    NSArray *result = [self getXMLArrayFromQuery:query];
    NSMutableArray *ads = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTAd *ad = [[HyBidVASTAd alloc] initWithDocumentArray:self.vastDocumentArray atIndex:i];
        [ads addObject:ad];
    }
    return ads;
}

- (NSArray<NSURL *> *)errors
{
    NSString *query = @"//Error";
    return [self resultsForQuery:query];
}

// We deliberately do not declare this method in the header file in order to hide it.
// It should be used only be the VAST2Parser to build the model.
// It should not be used by anybody else receiving the model object.
- (void)addVASTDocument:(NSData *)vastDocument {
    if (!self.vastDocumentArray) {
        self.vastDocumentArray = [NSMutableArray array];
    }
    
    [self.vastDocumentArray removeAllObjects];
    [self.vastDocumentArray addObject:vastDocument];
}

// MARK: - Helper Methods

- (NSString *)getXMLValueFromQuery:(NSString *)query
{
    // sanity check
    if ([self.vastDocumentArray count] == 0) {
        return nil;
    }

    NSString *xmlValue;
    NSArray *results = performXMLXPathQuery(self.vastDocumentArray[0], query);
    // there should be only a single result
    if ([results count] > 0) {
        NSDictionary *attribute = results[0];
        xmlValue = attribute[@"nodeContent"];
    }
    return xmlValue;
}

- (NSArray *)getXMLArrayFromQuery:(NSString *)query
{
    // sanity check
    if ([self.vastDocumentArray count] == 0) {
        return nil;
    }

    return performXMLXPathQuery(self.vastDocumentArray[0], query);
}

- (NSArray *)resultsForQuery:(NSString *)query {
    NSMutableArray *array;
    NSString *elementName = [query stringByReplacingOccurrencesOfString:@"/" withString:@""];

    for (NSData *document in self.vastDocumentArray) {
        NSArray *results = performXMLXPathQuery(document, query);
        for (NSDictionary *result in results) {
            if (!array) {
                array = [NSMutableArray array];
            }
            NSString *urlString = [self content:result];
            if(urlString != nil) {
                [array addObject:urlString];
            }
        }
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"VAST Model returning %@ array with %lu element(s)", elementName, (unsigned long)[array count]]];
    return array;
}

- (NSString *)content:(NSDictionary *)node {
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }

    // this is for CDATA
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

- (NSString *)vastString
{
    if (self.vastDocumentArray != nil && [self.vastDocumentArray count] > 0) {
        return [[NSString alloc] initWithData: self.vastDocumentArray[0] encoding:NSUTF8StringEncoding] ;
    }
    return nil;
}

- (void)dealloc {
    self.vastDocumentArray = nil;
}

@end
