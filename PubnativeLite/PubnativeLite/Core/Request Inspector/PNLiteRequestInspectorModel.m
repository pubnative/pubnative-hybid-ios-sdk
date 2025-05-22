// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteRequestInspectorModel.h"

@implementation PNLiteRequestInspectorModel

- (void)dealloc {
    self.url = nil;
    self.response = nil;
    self.latency = nil;
    self.reqestBody = nil;
}

- (instancetype)initWithURL:(NSString *)url withResponse:(NSString *)response withLatency:(NSNumber *)latency withRequestBody:(NSData *)reqestBody {
    self = [super init];
    if (self) {
        self.url = url;
        self.reqestBody = reqestBody;
        self.response = response;
        self.latency = latency;
    }
    return self;
}

@end
