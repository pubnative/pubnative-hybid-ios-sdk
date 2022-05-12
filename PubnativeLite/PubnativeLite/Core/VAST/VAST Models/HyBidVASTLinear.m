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

#import "HyBidVASTLinear.h"
#import "HyBidVASTTrackingEvents.h"

@interface HyBidVASTLinear ()

@property (nonatomic, strong)HyBidXMLElementEx *inLineXMLElement;

@end

@implementation HyBidVASTLinear

- (instancetype)initWithInLineXMLElement:(HyBidXMLElementEx *)inLineXMLElement
{
    if (inLineXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.inLineXMLElement = inLineXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)skipOffset
{
    NSString *skipOffset = [self.inLineXMLElement attribute:@"skipoffset"];
    return skipOffset == nil ? @"-1" : skipOffset;
}

// MARK: - Elements

- (NSString *)duration
{
    if ([[self.inLineXMLElement query:@"/Duration"] count] > 0) {
        HyBidXMLElementEx *durationElement = [[self.inLineXMLElement query:@"/Duration"] firstObject];
        return [durationElement value];
    }
    return nil;
}

- (HyBidVASTAdParameters *)adParameters
{
    if ([[self.inLineXMLElement query:@"/AdParameters"] count] > 0) {
        HyBidXMLElementEx *adParametersElement = [[self.inLineXMLElement query:@"/AdParameters"] firstObject];
        return [[HyBidVASTAdParameters alloc] initWithAdParametersXMLElement:adParametersElement];
    }
    return nil;
}

- (NSArray<HyBidVASTIcon *> *)icons
{
    NSMutableArray<HyBidVASTIcon *> *array = [[NSMutableArray alloc] init];
    
    if ([[self.inLineXMLElement query:@"/Icons"] count] > 0) {
        HyBidXMLElementEx *iconsElement = [[self.inLineXMLElement query:@"/Icons"] firstObject];
        
        NSString *query = @"/Icon";
        NSArray<HyBidXMLElementEx *> *result = [iconsElement query:query];
        
        for (int i = 0; i < [result count]; i++) {
            HyBidVASTIcon *icon = [[HyBidVASTIcon alloc] initWithIconXMLElement:result[i]];
            [array addObject:icon];
        }
    }
    
    return array;
}

- (HyBidVASTMediaFiles *)mediaFiles
{
    if ([[self.inLineXMLElement query:@"/MediaFiles"] count] > 0) {
        HyBidXMLElementEx *mediaFilesElement = [[self.inLineXMLElement query:@"/MediaFiles"] firstObject];
        return [[HyBidVASTMediaFiles alloc] initWithMediaFilesXMLElement:mediaFilesElement];
    }
    return nil;
}

- (HyBidVASTTrackingEvents *)trackingEvents
{
    if ([[self.inLineXMLElement query:@"/TrackingEvents"] count] > 0) {
        HyBidXMLElementEx *trackingEventsElement = [[self.inLineXMLElement query:@"/TrackingEvents"] firstObject];
        HyBidVASTTrackingEvents *trackingEvents = [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:trackingEventsElement];
        return trackingEvents;
    }
    return nil;
}

- (HyBidVASTVideoClicks *)videoClicks
{
    if ([[self.inLineXMLElement query:@"/VideoClicks"] count] > 0) {
        HyBidXMLElementEx *videoClicksElement = [[self.inLineXMLElement query:@"/VideoClicks"] firstObject];
        HyBidVASTVideoClicks *videoClicks = [[HyBidVASTVideoClicks alloc] initWithVideoClicksXMLElement:videoClicksElement];
        return videoClicks;
    }
    return nil;
}

@end
