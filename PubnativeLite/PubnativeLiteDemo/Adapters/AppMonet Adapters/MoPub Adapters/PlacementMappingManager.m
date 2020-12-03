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
    static PlacementMappingManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (AdRequestInfo *)getEcmpMappingFrom:(HyBidAdSize *)adSize andEcpm:(NSString *)eCPM
{
    NSString *newCPM = [NSString stringWithFormat:@"%@", eCPM];
    if (self.model == nil ||
        [self.model getAdSizes] == nil ||
        [[self.model getAdSizes] count] == 0 ||
        [[self.model getAppToken] isEqualToString:@""] ||
        [newCPM isEqualToString:@""]) {
        return nil;
    }
    
    NSString *adSizeKey = [self getAdSizeLabelFrom:adSize];
    NSDictionary *sizeMapping = [[self.model getAdSizes] objectForKey:adSizeKey];
    
    if (sizeMapping == nil || [sizeMapping count] == 0) {
        return nil;
    }
    
    NSString *zoneID = [sizeMapping objectForKey:newCPM];
    if ([zoneID length] == 0) {
        return nil;
    }
    
    return [[AdRequestInfo alloc] initWith:[self.model getAppToken] andZoneID:zoneID];
}

- (NSString *)getAdSizeLabelFrom:(HyBidAdSize *)adSize
{
    if (adSize.height == HyBidAdSize.SIZE_INTERSTITIAL.height && adSize.width == HyBidAdSize.SIZE_INTERSTITIAL.width && adSize.layoutSize == HyBidAdSize.SIZE_INTERSTITIAL.layoutSize) {
        return @"fullscreen";
    }
    if (adSize.height == HyBidAdSize.SIZE_768x1024.height && adSize.width == HyBidAdSize.SIZE_768x1024.width && adSize.layoutSize == HyBidAdSize.SIZE_768x1024.layoutSize) {
        return @"768x1024";
    }
    if (adSize.height == HyBidAdSize.SIZE_1024x768.height && adSize.width == HyBidAdSize.SIZE_1024x768.width && adSize.layoutSize == HyBidAdSize.SIZE_1024x768.layoutSize) {
        return @"1024x768";
    }
    if (adSize.height == HyBidAdSize.SIZE_300x600.height && adSize.width == HyBidAdSize.SIZE_300x600.width && adSize.layoutSize == HyBidAdSize.SIZE_300x600.layoutSize) {
        return @"300x600";
    }
    if (adSize.height == HyBidAdSize.SIZE_160x600.height && adSize.width == HyBidAdSize.SIZE_160x600.width && adSize.layoutSize == HyBidAdSize.SIZE_160x600.layoutSize) {
        return @"160x600";
    }
    if (adSize.height == HyBidAdSize.SIZE_320x480.height && adSize.width == HyBidAdSize.SIZE_320x480.width && adSize.layoutSize == HyBidAdSize.SIZE_320x480.layoutSize) {
        return @"320x480";
    }
    if (adSize.height == HyBidAdSize.SIZE_480x320.height && adSize.width == HyBidAdSize.SIZE_480x320.width && adSize.layoutSize == HyBidAdSize.SIZE_480x320.layoutSize) {
        return @"480x320";
    }
    if (adSize.height == HyBidAdSize.SIZE_300x250.height && adSize.width == HyBidAdSize.SIZE_300x250.width && adSize.layoutSize == HyBidAdSize.SIZE_300x250.layoutSize) {
        return @"300x250";
    }
    if (adSize.height == HyBidAdSize.SIZE_250x250.height && adSize.width == HyBidAdSize.SIZE_250x250.width && adSize.layoutSize == HyBidAdSize.SIZE_250x250.layoutSize) {
        return @"250x250";
    }
    if (adSize.height == HyBidAdSize.SIZE_320x100.height && adSize.width == HyBidAdSize.SIZE_320x100.width && adSize.layoutSize == HyBidAdSize.SIZE_320x100.layoutSize) {
        return @"320x100";
    }
    if (adSize.height == HyBidAdSize.SIZE_728x90.height && adSize.width == HyBidAdSize.SIZE_728x90.width && adSize.layoutSize == HyBidAdSize.SIZE_728x90.layoutSize) {
        return @"728x90";
    }
    if (adSize.height == HyBidAdSize.SIZE_300x50.height && adSize.width == HyBidAdSize.SIZE_300x50.width && adSize.layoutSize == HyBidAdSize.SIZE_300x50.layoutSize) {
        return @"300x50";
    }
    return @"300x50";
}

- (NSString *)textFromAsset
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hybid_mapping" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return content;
}

@end
