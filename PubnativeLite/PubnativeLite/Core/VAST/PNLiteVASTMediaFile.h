// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface PNLiteVASTMediaFile : NSObject

@property (nonatomic, copy, readonly) NSString *id_;  // add trailing underscore to id_ to avoid conflict with reserved keyword "id".
@property (nonatomic, copy, readonly) NSString *delivery;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, assign, readonly) int bitrate;
@property (nonatomic, assign, readonly) int width;
@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) BOOL scalable;
@property (nonatomic, assign, readonly) BOOL maintainAspectRatio;
@property (nonatomic, copy, readonly) NSString *apiFramework;
@property (nonatomic, strong, readonly) NSURL *url;

- (id)initWithId:(NSString *)id_ // add trailing underscore
        delivery:(NSString *)delivery
            type:(NSString *)type
         bitrate:(NSString *)bitrate
           width:(NSString *)width
          height:(NSString *)height
        scalable:(NSString *)scalable
maintainAspectRatio:(NSString *)maintainAspectRatio
    apiFramework:(NSString *)apiFramework
             url:(NSString *)url;

@end
