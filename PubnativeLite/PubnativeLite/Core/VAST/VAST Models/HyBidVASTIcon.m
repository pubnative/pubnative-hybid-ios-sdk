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

@interface HyBidVASTIcon ()

@property (nonatomic, strong)HyBidXMLElementEx *iconXmlElement;

@end

@implementation HyBidVASTIcon

- (instancetype)initWithIconXMLElement:(HyBidXMLElementEx *)iconXMLElement
{
    self = [super init];
    if (self) {
        self.iconXmlElement = iconXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)duration
{
    return [self.iconXmlElement attribute:@"duration"];
}

- (NSString *)height
{
    return [self.iconXmlElement attribute:@"height"];
}

- (NSString *)width
{
    return [self.iconXmlElement attribute:@"width"];
}

- (NSString *)offset
{
    return [self.iconXmlElement attribute:@"offset"];
}

- (NSString *)program
{
    return [self.iconXmlElement attribute:@"program"];
}

- (NSString *)pxRatio
{
    return [self.iconXmlElement attribute:@"pxratio"];
}

- (NSString *)xPosition
{
    return [self.iconXmlElement attribute:@"xPosition"];
}

- (NSString *)yPosition
{
    return [self.iconXmlElement attribute:@"yPosition"];
}

// MARK: - Elements

- (NSArray<HyBidVASTIconViewTracking *> *)iconViewTracking
{
    NSArray<HyBidXMLElementEx *> *result = [self.iconXmlElement query:@"/IconViewTracking"];
    NSMutableArray<HyBidVASTIconViewTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTIconViewTracking *iconViewTracking = [[HyBidVASTIconViewTracking alloc] initWithIconViewTrackingXMLElement:result[i]];
        [array addObject:iconViewTracking];
    }
    
    return array;
}

- (NSArray<HyBidVASTStaticResource *> *)staticResources
{
    NSArray<HyBidXMLElementEx *> *result = [self.iconXmlElement query:@"/StaticResource"];
    NSMutableArray<HyBidVASTStaticResource *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTStaticResource *staticResource = [[HyBidVASTStaticResource alloc] initWithStaticResourceXMLElement:result[i]];
        [array addObject:staticResource];
    }
    
    return array;
}

- (HyBidVASTIconClicks *)iconClicks
{
    if ([[self.iconXmlElement query:@"/IconClicks"] count] > 0) {
        HyBidXMLElementEx *iconClicksElement = [[self.iconXmlElement query:@"/IconClicks"] firstObject];
        HyBidVASTIconClicks *iconClicks = [[HyBidVASTIconClicks alloc] initWithIconClicksXMLElement:iconClicksElement];
        
        return iconClicks;
    }
    return nil;
}

@end
