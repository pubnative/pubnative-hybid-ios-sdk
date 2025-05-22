// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface SignalData : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *placement;

- (instancetype)initWithSignalDataText:(NSString *)signalDataText withAdPlacement:(NSNumber *)placement;

@end
