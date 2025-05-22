// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface PNLiteRequestInspectorModel : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *response;
@property (nonatomic, strong) NSNumber *latency;
@property (nonatomic, strong) NSData *reqestBody;

- (instancetype)initWithURL:(NSString *)url withResponse:(NSString *)response withLatency:(NSNumber *)latency withRequestBody:(NSData *)reqestBody;

@end
