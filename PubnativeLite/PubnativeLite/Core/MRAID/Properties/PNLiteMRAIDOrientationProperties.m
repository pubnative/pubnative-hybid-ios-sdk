// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteMRAIDOrientationProperties.h"

@implementation PNLiteMRAIDOrientationProperties

- (id)init {
    self = [super init];
    if (self) {
        _allowOrientationChange = YES;
        _forceOrientation = PNLiteMRAIDForceOrientationNone;
    }
    return self;
}

+ (PNLiteMRAIDForceOrientation)MRAIDForceOrientationFromString:(NSString *)s {
    NSArray *names = @[ @"portrait", @"landscape", @"none" ];
    NSUInteger i = [names indexOfObject:s];
    if (i != NSNotFound) {
        return (PNLiteMRAIDForceOrientation)i;
    }
    // Use none for the default value
    return PNLiteMRAIDForceOrientationNone;
}

@end
