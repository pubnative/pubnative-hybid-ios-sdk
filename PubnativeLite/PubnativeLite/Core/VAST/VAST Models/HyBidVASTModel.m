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
#import "HyBidLogger.h"
#import "HyBidXMLEx.h"

@interface HyBidVASTModel ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@property (nonatomic, strong)HyBidXMLEx *parser;

@end

@implementation HyBidVASTModel

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        [self addVASTDocument:data];
    }
    return self;
}

- (NSString *)version
{
    return [[self.parser rootElement] attribute:@"version"];
}

- (NSArray<HyBidVASTAd *> *)ads
{
    NSMutableArray *ads = [[NSMutableArray alloc] init];
    
    NSArray *result = [[self.parser rootElement] query:@"Ad"];
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTAd *ad = [[HyBidVASTAd alloc] initWithXMLElement:result[i]];
        [ads addObject:ad];
    }
    return ads;
}

- (NSArray<NSURL *> *)errors
{
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    for (HyBidXMLElementEx *element in [[self.parser rootElement] query:@"Error"]) {
        if (element.value != nil) {
            NSURL *url = [[NSURL alloc] initWithString:element.value];
            [errors addObject:url];
        }
    }
    return errors;
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
    
    NSString *xml = [[NSString alloc] initWithData:self.vastDocumentArray[0] encoding:NSUTF8StringEncoding];
    self.parser = [HyBidXMLEx parserWithXML:xml];
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
    self.parser = nil;
}

@end
