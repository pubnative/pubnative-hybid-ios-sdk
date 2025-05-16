// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVASTMediaFile.h"

@implementation PNLiteVASTMediaFile

- (id)initWithId:(NSString *)id_
        delivery:(NSString *)delivery
            type:(NSString *)type
         bitrate:(NSString *)bitrate
           width:(NSString *)width
          height:(NSString *)height
        scalable:(NSString *)scalable
maintainAspectRatio:(NSString *)maintainAspectRatio
    apiFramework:(NSString *)apiFramework
             url:(NSString *)url {
    self = [super init];
    if (self) {
        _id_ = id_;
        _delivery = delivery;
        _type = type;
        _bitrate = bitrate ? [bitrate intValue] : 0;
        _width = width ? [width intValue] : 0;
        _height = height ? [height intValue] : 0;
        _scalable = scalable == nil || [scalable boolValue];
        _maintainAspectRatio = maintainAspectRatio != nil && [maintainAspectRatio boolValue];
        _apiFramework = apiFramework;
        _url = [NSURL URLWithString:url];
    }
    return self;
}

- (void)dealloc {
    _url = nil;
}

@end
