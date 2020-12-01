//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "PlacementMappingManager.h"
#import "ZoneIDMappingModel.h"
#import "AdRequestInfo.h"
#import "HyBidAdSize.h"

@interface PlacementMappingManager ()

@property (nonatomic, strong) ZoneIDMappingModel *model;

@end

@implementation PlacementMappingManager

static PlacementMappingManager *_sharedInstance = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *mappingJSON = [self textFromAsset];
        if ([mappingJSON length] != 0) {
            self.model = [[ZoneIDMappingModel alloc] initWithJSONString:mappingJSON];
        }
    }
    return self;
}

+ (PlacementMappingManager *)sharedInstance
{
    @synchronized ([PlacementMappingManager class]) {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
            return _sharedInstance;
        }
        return nil;
    }
}

- (AdRequestInfo *)getEcmpMappingFrom:(HyBidAdSize *)adSize andEcpm:(NSString *)eCPM
{
    if (self.model == nil ||
        [self.model getAdSizes] == nil ||
        [[self.model getAdSizes] count] == 0 ||
        [[self.model getAppToken] length] == 0 ||
        [eCPM length] == 0) {
        return nil;
    }
    
    NSString *adSizeKey = [self getAdSizeLabelFrom:adSize];
    NSDictionary *sizeMapping = [[self.model getAdSizes] objectForKey:adSizeKey];
    
    if (sizeMapping == nil || [sizeMapping count] == 0) {
        return nil;
    }
    
    NSString *zoneID = [sizeMapping objectForKey:eCPM];
    if ([zoneID length] == 0) {
        return nil;
    }
    
    return [[AdRequestInfo alloc] initWith:[self.model getAppToken] andZoneID:zoneID];
}

- (NSString *)getAdSizeLabelFrom:(HyBidAdSize *)adSize
{
    if (adSize == HyBidAdSize.SIZE_INTERSTITIAL) return @"fullscreen";
    if (adSize == HyBidAdSize.SIZE_768x1024) return @"768x1024";
    if (adSize == HyBidAdSize.SIZE_1024x768) return @"1024x768";
    if (adSize == HyBidAdSize.SIZE_300x600) return @"300x600";
    if (adSize == HyBidAdSize.SIZE_160x600) return @"160x600";
    if (adSize == HyBidAdSize.SIZE_320x480) return @"320x480";
    if (adSize == HyBidAdSize.SIZE_480x320) return @"480x320";
    if (adSize == HyBidAdSize.SIZE_300x250) return @"300x250";
    if (adSize == HyBidAdSize.SIZE_250x250) return @"250x250";
    if (adSize == HyBidAdSize.SIZE_320x100) return @"320x100";
    if (adSize == HyBidAdSize.SIZE_728x90) return @"728x90";
    if (adSize == HyBidAdSize.SIZE_300x50) return @"300x50";
    return @"300x50";
}

- (NSString *)textFromAsset
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hybid_mapping" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return content;
}

@end
