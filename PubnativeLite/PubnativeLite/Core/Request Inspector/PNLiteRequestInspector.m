// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteRequestInspector.h"

@implementation PNLiteRequestInspector

- (void)dealloc {
    self.lastInspectedRequest = nil;
}

+ (instancetype)sharedInstance {
    static PNLiteRequestInspector * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PNLiteRequestInspector alloc] init];
    });
    return _instance;
}

- (void)setLastRequestInspectorWithURL:(NSString *)url withResponse:(NSString *)response withLatency:(NSNumber *)latency withRequestBody:(NSData *)requestBody {
    self.lastInspectedRequest = [[PNLiteRequestInspectorModel alloc] initWithURL:url withResponse:response withLatency:latency withRequestBody:requestBody];
}

@end
