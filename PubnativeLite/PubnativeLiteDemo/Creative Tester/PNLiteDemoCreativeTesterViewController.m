// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoCreativeTesterViewController.h"
#import "PNLiteHttpRequest.h"
#import "Markup.h"
#import "PNLiteDemoMarkupDetailViewController.h"
#import "UITextField+KeyboardDismiss.h"

#import <HyBid/HyBid.h>

@interface PNLiteDemoCreativeTesterViewController () <PNLiteHttpRequestDelegate, HyBidInterstitialAdDelegate>

@property (weak, nonatomic) IBOutlet UITextField *creativeIdTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *adSizeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic) HyBidMarkupPlacement placement;
@property (strong, nonatomic) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) Markup *markup;

@end

@implementation PNLiteDemoCreativeTesterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Creative Tester";
    [self.creativeIdTextField addDismissKeyboardButtonWithTitle:@"Done" withTarget:self withSelector:@selector(dismissKeyboard)];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)loadButtonTapped:(UIButton *)sender {
    [self requestAd];
}

- (BOOL)canRequestAd {
    if ([[self.creativeIdTextField text] length] > 0) {
        return YES;
    } else {
        [self showAlertControllerWithMessage:@"Creative ID field cannot be empty."];
        return NO;
    }
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    if ([self canRequestAd]) {
        NSString *creativeID = [[self.creativeIdTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://docker.creative-serving.com/preview?cr=%@&type=adi", creativeID];
        [[PNLiteHttpRequest alloc] startWithUrlString:urlString withMethod:@"GET" delegate:self];
    }
}

-(void)deinit {
    self.markup = nil;
    self.interstitialAd = nil;
}

// MARK: - Helper Methods

- (void)displayAd {
    switch (self.placement) {
        case HyBidDemoAppPlacementBanner:
            [self displayAdModally:YES];
            break;
        case HyBidDemoAppPlacementMRect:
            [self displayAdModally:YES];
            break;
        case HyBidDemoAppPlacementLeaderboard: {
            [self displayAdModally:NO];
            break;
        }
        case HyBidDemoAppPlacementInterstitial: {
            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
            [self.interstitialAd prepareCustomMarkupFrom:self.markup.text];
            break;
        }
        case HyBidDemoAppPlacementRewarded:
            break;
    }
}

-(void)displayAdModally:(BOOL)modal {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Markup" bundle:[NSBundle mainBundle]];
    PNLiteDemoMarkupDetailViewController *markupDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"MarkupDetailViewController"];
    markupDetailVC.markup = self.markup;
    if (modal) {
        [self.navigationController presentViewController:markupDetailVC animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:markupDetailVC animated:YES];
    }
}

- (void)invokeDidFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    NSString *adString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([adString length] == 0) {
        [self showAlertControllerWithMessage:@"No content for the Creative ID received"];
        return;
    }
    
    switch ([self.adSizeSegmentedControl selectedSegmentIndex]) {
        case 0: {
            self.placement = HyBidDemoAppPlacementBanner;
            break;
        }
        case 1: {
            self.placement = HyBidDemoAppPlacementMRect;
            break;
        }
        case 2: {
            self.placement = HyBidDemoAppPlacementLeaderboard;
            break;
        }
        case 3: {
            self.placement = HyBidDemoAppPlacementInterstitial;
            break;
        }
    }
    
    self.markup = [[Markup alloc] initWithMarkupText:adString withAdPlacement: self.placement];
    [self displayAd];
    self.debugButton.hidden = NO;
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFail:error];
    self.debugButton.hidden = NO;
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    [self.interstitialAd show];
}

- (void)interstitialDidFailWithError:(NSError *)error {
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
}

- (void)interstitialDidTrackClick {
    NSLog(@"Interstitial did track click");
}

- (void)interstitialDidTrackImpression {
    NSLog(@"Interstitial did track impression");
}

- (void)interstitialDidDismiss {
    NSLog(@"Interstitial did dismiss");
}

@end
