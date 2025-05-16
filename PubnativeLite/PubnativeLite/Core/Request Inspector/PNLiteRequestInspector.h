// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "PNLiteRequestInspectorModel.h"

@interface PNLiteRequestInspector : NSObject

@property (nonatomic, strong) PNLiteRequestInspectorModel *lastInspectedRequest;

+ (instancetype)sharedInstance;
- (void)setLastRequestInspectorWithURL:(NSString *)url withResponse:(NSString *)response withLatency:(NSNumber *)latency withRequestBody:(NSData *)requestBody ;

@end
