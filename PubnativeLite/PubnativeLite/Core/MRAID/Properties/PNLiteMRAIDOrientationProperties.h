// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

typedef enum {
    PNLiteMRAIDForceOrientationPortrait,
    PNLiteMRAIDForceOrientationLandscape,
    PNLiteMRAIDForceOrientationNone
} PNLiteMRAIDForceOrientation;

@interface PNLiteMRAIDOrientationProperties : NSObject

@property (nonatomic, assign) BOOL allowOrientationChange;
@property (nonatomic, assign) PNLiteMRAIDForceOrientation forceOrientation;

+ (PNLiteMRAIDForceOrientation)MRAIDForceOrientationFromString:(NSString *)s;

@end
