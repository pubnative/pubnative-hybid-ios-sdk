// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteOrientationManager.h"

@interface PNLiteOrientationManager ()

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation PNLiteOrientationManager


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.orientation = UIInterfaceOrientationUnknown;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static PNLiteOrientationManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PNLiteOrientationManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)load {
    [[PNLiteOrientationManager sharedInstance] startListening];
}

+ (UIInterfaceOrientation)orientation {
    if([PNLiteOrientationManager sharedInstance].orientation == UIInterfaceOrientationUnknown) {
        [PNLiteOrientationManager sharedInstance].orientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return [PNLiteOrientationManager sharedInstance].orientation;
}

- (void)startListening {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}


- (void)didChangeStatusBarOrientation:(NSNotification *)notification {
    if ([PNLiteOrientationManager sharedInstance].orientation != [UIApplication sharedApplication].statusBarOrientation) {
        [PNLiteOrientationManager sharedInstance].orientation = [UIApplication sharedApplication].statusBarOrientation;
        [self sendDidChangeOrientationNotication];
    }
}

- (void)sendDidChangeOrientationNotication {
    [self.delegate orientationManagerDidChangeOrientation];
}

@end
