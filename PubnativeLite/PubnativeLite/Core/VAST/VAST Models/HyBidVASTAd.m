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

#import "HyBidVASTAd.h"
#import "HyBidVASTAdCategory.h"

@interface HyBidVASTAd ()

@property (nonatomic, strong)HyBidXMLElementEx *xmlElement;

@end

@implementation HyBidVASTAd

- (instancetype)initWithXMLElement:(HyBidXMLElementEx *)xmlElement
{
    self = [super init];
    if (self) {
        self.xmlElement = xmlElement;
    }
    return self;
}

- (HyBidVASTAdType)adType
{
    HyBidVASTAdType adType = HyBidVASTAdType_NONE;
    NSString *inlineQuery = @"/InLine";
    NSString *wrapperQuery = @"/Wrapper";
        
    if ([[self.xmlElement query:inlineQuery] count] != 0) {
        return HyBidVASTAdType_INLINE;
    } else if ([[self.xmlElement query:wrapperQuery] count] != 0) {
        return HyBidVASTAdType_WRAPPER;
    }
    
    return adType;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.xmlElement attribute:@"id"];
}

- (NSString *)sequence
{
    return [self.xmlElement attribute:@"sequence"];
}

- (BOOL)isConditionalAd
{
    return [[self.xmlElement attribute:@"conditionalAd"] isEqualToString:@"true"] ? YES : NO;
}

// MARK: - Elements

/**
 The Ad element requires exactly one child, which can either be an <InLine> or <Wrapper> element.
 */
- (HyBidVASTAdInline *)inLine
{
    if ([[self.xmlElement query:@"/InLine"] count] > 0) {
        return [[HyBidVASTAdInline alloc] initWithInLineXMLElement:[[self.xmlElement query:@"/InLine"] firstObject]];
    }
    return nil;
}

/**
 The Ad element requires exactly one child, which can either be an <InLine> or <Wrapper> element.
 */
- (HyBidVASTAdWrapper *)wrapper
{
    if ([[self.xmlElement query:@"/Wrapper"] count] > 0) {
        return [[HyBidVASTAdWrapper alloc] initWithXMLElement:[[self.xmlElement query:@"/Wrapper"] firstObject]];
    }
    return nil;
}

@end
