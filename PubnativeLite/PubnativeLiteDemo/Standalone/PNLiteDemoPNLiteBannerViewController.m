// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoPNLiteBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "Quote.h"
#import "QuoteCell.h"
#import "BannerAdViewCell.h"
#import "HyBidSKAdNetworkViewController.h"

@interface PNLiteDemoPNLiteBannerViewController () <HyBidAdViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoRefreshSwitch;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet UISwitch *adCachingSwitch;
@property (nonatomic, strong) HyBidAdView *bannerAdView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creativeIDTopConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isUsingOpenRTB;
@property (weak, nonatomic) IBOutlet UISegmentedControl *adFormatSwitch;

@end

@implementation PNLiteDemoPNLiteBannerViewController

- (void)dealloc {
    [self.bannerAdView stopAutoRefresh];
    self.bannerAdView = nil;
    self.dataSource = nil;
    self.bannerLoaderIndicator = nil;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bannerLoaderIndicator stopAnimating];
    self.creativeIDTopConstraint.constant = 12;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;

    self.navigationItem.title = @"HyBid Banner";
    self.adFormatSwitch.accessibilityIdentifier = @"openRTBAdFormatSwitch";
    self.adFormatSwitch.hidden = YES;
    
    [self populateDataSource];
    self.bannerAdView = [[HyBidAdView alloc] initWithSize:[PNLiteDemoSettings sharedInstance].adSize];
    [self.dataSource addObject:self.bannerAdView];
}

- (IBAction)requestedAdFormat:(id)sender {
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1){
        self.adFormatSwitch.hidden = NO;
    } else {
        self.adFormatSwitch.hidden = YES;
    }
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.bannerAdView.hidden = YES;
    self.debugButton.hidden = YES;
    self.showAdButton.enabled = NO;
    self.prepareButton.enabled = NO;
    [self.bannerLoaderIndicator startAnimating];
    [self.bannerAdView setIsAutoCacheOnLoad:self.adCachingSwitch.isOn];
    if (self.isUsingOpenRTB.selectedSegmentIndex == 0) {
        [self.bannerAdView loadWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
    } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        if (self.adFormatSwitch.selectedSegmentIndex == 0) {
            [self.bannerAdView setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdBanner];
        } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
            [self.bannerAdView setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdVideo];
        }
        [self.bannerAdView loadExchangeAdWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
    }
}

- (IBAction)adCachingSwitchValueChanged:(UISwitch *)sender {
    self.prepareButton.hidden = sender.isOn;
    self.showAdButton.hidden = sender.isOn;
    self.bannerAdView.autoShowOnLoad = sender.isOn;
    self.creativeIDTopConstraint.constant = sender.isOn ? 12.0 : 88.0;
    [self.creativeIdLabel setNeedsDisplay];
}

- (IBAction)prepareButtonTapped:(UIButton *)sender {
    [self.bannerAdView prepare];
    self.prepareButton.enabled = NO;
}

- (IBAction)showBannerAdButtonTapped:(UIButton *)sender {
    [self.bannerAdView show];
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
}

- (IBAction)autoRefreshSwitchValueChanged:(UISwitch *)sender {
    if (sender.isOn) {
        self.bannerAdView.autoRefreshTimeInSeconds = 30;
    } else {
        [self.bannerAdView stopAutoRefresh];
    }
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        [self setCreativeIDLabelWithString:self.bannerAdView.ad.openRTBCreativeID];
    } else {
        [self setCreativeIDLabelWithString:self.bannerAdView.ad.creativeID];
    }
    self.bannerAdView.hidden = NO;
    self.debugButton.hidden = NO;
    self.prepareButton.enabled = !self.adCachingSwitch.isOn;
    self.showAdButton.enabled = YES;
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track impression:");
}

- (void)adViewWillRefresh:(HyBidAdView *)adView {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
}

#pragma mark - UITableViewDatasource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[Quote class]]) {
        QuoteCell *quoteCell = (QuoteCell *)[tableView dequeueReusableCellWithIdentifier:@"quoteCell"];
        Quote *quote = self.dataSource[indexPath.row];
        quoteCell.quoteTextLabel.text = quote.quoteText;
        quoteCell.quoteAutorLabel.text = quote.quoteAuthor;
        return quoteCell;
    } else {
        BannerAdViewCell *bannerAdViewCell = [tableView dequeueReusableCellWithIdentifier:@"bannerAdViewCell" forIndexPath:indexPath];
        self.bannerLoaderIndicator = bannerAdViewCell.bannerAdViewLoaderIndicator;
        
        [self.bannerAdView setAccessibilityLabel:@"BannerAdView"];
        [self.bannerAdView setAccessibilityIdentifier:@"bannerAdView"];
        [bannerAdViewCell.bannerAdViewContainer addSubview:self.bannerAdView];
        
        bannerAdViewCell.bannerAdContainerWidthConstraint.constant = [PNLiteDemoSettings sharedInstance].adSize.width;
        bannerAdViewCell.bannerAdContainerHeightConstraint.constant = [PNLiteDemoSettings sharedInstance].adSize.height;
        return bannerAdViewCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[Quote class]]) {
        return 100;
    } else {
        return [PNLiteDemoSettings sharedInstance].adSize.height + 40;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Utils

- (void)populateDataSource {
    self.dataSource = [[NSMutableArray alloc]initWithObjects:
                       [[Quote alloc]initWithText:@"Our world is built on biology and once we begin to understand it, it then becomes a technology" andAuthor:@"Ryan Bethencourt"],
                       [[Quote alloc]initWithText:@"Happiness is not an ideal of reason but of imagination" andAuthor:@"Immanuel Kant"],
                       [[Quote alloc]initWithText:@"Science and technology revolutionize our lives, but memory, tradition and myth frame our response." andAuthor:@"Arthur M. Schlesinger"],
                       [[Quote alloc]initWithText:@"It's not a faith in technology. It's faith in people" andAuthor:@"Steve Jobs"],
                       [[Quote alloc]initWithText:@"We can't blame the technology when we make mistakes." andAuthor:@"Tim Berners-Lee"],
                       [[Quote alloc]initWithText:@"Life must be understood backward. But it must be lived forward." andAuthor:@"Søren Kierkegaard"],
                       [[Quote alloc]initWithText:@"Happiness can be found, even in the darkest of times, if one only remembers to turn on the light." andAuthor:@"Albus Dumbledore"],
                       [[Quote alloc]initWithText:@"To live a creative life, we must lose our fear of being wrong." andAuthor:@"Joseph Chilton Pearce"],
                       [[Quote alloc]initWithText:@"It is undesirable to believe a proposition when there is no ground whatever for supposing it true." andAuthor:@"Bertrand Russell"],
                       [[Quote alloc]initWithText:@"There's always a bigger fish." andAuthor:@"Qui-Gon Jinn"],
                       [[Quote alloc]initWithText:@"A wizard is never late. Nor is he early. He arrives precisely when he means to." andAuthor:@"Gandalf"],
                       [[Quote alloc]initWithText:@"Moonlight drowns out all but the brightest stars." andAuthor:@"J. R. R. Tolkien, The Lord of the Rings"],
                       [[Quote alloc]initWithText:@"A hunted man sometimes wearies of distrust and longs for friendship." andAuthor:@"J. R. R. Tolkien, The Lord of the Rings"],
                       nil];
}

@end
