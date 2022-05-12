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

#import "HyBidVASTIconClicks.h"

@interface HyBidVASTIconClicks ()

@property (nonatomic, strong)HyBidXMLElementEx *iconClicksXMLElement;

@end

@implementation HyBidVASTIconClicks

- (instancetype)initWithIconClicksXMLElement:(HyBidXMLElementEx *)iconClicksXMLElement
{
    if (iconClicksXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.iconClicksXMLElement = iconClicksXMLElement;
    }
    return self;
}

- (HyBidVASTIconClickThrough *)iconClickThrough
{
    if ([[self.iconClicksXMLElement query:@"/IconClickThrough"] count] > 0) {
        HyBidXMLElementEx *iconClickThroughElement = [[self.iconClicksXMLElement query:@"/IconClickThrough"] firstObject];
        HyBidVASTIconClickThrough *iconClickThrough = [[HyBidVASTIconClickThrough alloc] initWithIconClickThroughXMLElement:iconClickThroughElement];
        
        return iconClickThrough;
    }
    return nil;
}

- (NSArray<HyBidVASTIconClickTracking *> *)iconClickTracking
{
    NSArray<HyBidXMLElementEx *> *result = [self.iconClicksXMLElement query:@"/IconClickTracking"];
    NSMutableArray<HyBidVASTIconClickTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTIconClickTracking *iconClickTracking = [[HyBidVASTIconClickTracking alloc] initWithIconClickTrackingXMLElement:result[i]];
        [array addObject:iconClickTracking];
    }
    
    return array;
}

@end
