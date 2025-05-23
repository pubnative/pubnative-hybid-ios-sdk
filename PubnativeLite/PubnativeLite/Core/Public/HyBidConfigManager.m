// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidConfigManager.h"
#import "PNLiteHttpRequest.h"
#import "HyBidConfigResponseModel.h"
#import "HyBidError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSString *const HyBidConfigResponseOK = @"ok";
NSString *const HyBidConfigResponseError = @"error";
NSInteger const HyBidConfigResponseStatusOK = 200;
NSInteger const HyBidConfigResponseStatusRequestMalformed = 422;
NSString *const HyBidConfigProductionURL = @"https://sdkc.vervegroupinc.net/config?app_token=";

@interface HyBidConfigManager () <PNLiteHttpRequestDelegate>

@property (nonatomic, copy) ConfigManagerCompletionBlock completionBlock;
@property (nonatomic, strong) NSString *HyBidConfigURL;

@end

@implementation HyBidConfigManager

- (void)dealloc {
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedManager {
    static HyBidConfigManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HyBidConfigManager alloc] init];
    });
    return instance;
}

- (void)setHyBidConfigURLToProduction {
    self.HyBidConfigURL = [NSString stringWithFormat:@"%@%@",HyBidConfigProductionURL, [HyBidSDKConfig sharedConfig].appToken];
}

- (void)setHyBidConfigURLToTestingWithURL:(NSString *)url {
    self.HyBidConfigURL = url;
}

- (void)requestConfigWithCompletion:(ConfigManagerCompletionBlock)completion {
    self.completionBlock = completion;
    if (self.HyBidConfigURL == nil || self.HyBidConfigURL.length == 0) {
        [self setHyBidConfigURLToProduction];
    }
    [[PNLiteHttpRequest alloc] startWithUrlString:self.HyBidConfigURL withMethod:@"GET" delegate:self];
}

- (NSDictionary *)createDictionaryFromData:(NSData *)data {
    NSError *parseError;
    NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&parseError];
    if (parseError) {
        return nil;
    } else {
        return jsonDictonary;
    }
}

- (void)processResponse:(HyBidConfigResponseModel *)response {
    HyBidConfigModel *configModel = [[HyBidConfigModel alloc] initWithDictionary:response.configs];
    HyBidConfig *config = [[HyBidConfig alloc] initWithData:configModel];
    self.completionBlock(config, nil);
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    self.completionBlock(nil, error);
}

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    if(HyBidConfigResponseStatusOK == statusCode || HyBidConfigResponseStatusRequestMalformed == statusCode) {
        NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
        if (jsonDictonary) {
            HyBidConfigResponseModel *response = [[HyBidConfigResponseModel alloc] initWithDictionary:jsonDictonary];
            if ([response.status isEqualToString:HyBidConfigResponseError]) {
                NSError *responseError = [NSError errorWithDomain:response.errorMessage code:HyBidErrorCodeInternal userInfo:nil];
                self.completionBlock(nil, responseError);
            } else {
                [self processResponse:response];
            }
        } else {
            self.completionBlock(nil, [NSError hyBidInvalidRemoteConfigData]);
        }
    } else {
        self.completionBlock(nil, [NSError hyBidServerError]);
    }
}

@end
