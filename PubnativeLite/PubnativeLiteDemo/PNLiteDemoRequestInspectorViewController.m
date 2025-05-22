// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoRequestInspectorDetailViewController.h"
#import "PNLiteDemoRequestInspectorViewController.h"
#import "PNLiteRequestInspector.h"

@interface PNLiteDemoRequestInspectorViewController ()

@property (weak, nonatomic) IBOutlet UITextView *requestTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestTextConstraint;

@property (weak, nonatomic) IBOutlet UITextView *latencyTextView;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) IBOutlet UIButton *viewRequestBodyButton;
@property (weak, nonatomic) IBOutlet UIButton *jsonRequestBodyButton;


@property (weak, nonatomic) IBOutlet UITextView *requestBodyTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestBodyTextConstraint;

@property (strong, nonatomic) NSArray *urlParameterList;
@property (strong, nonatomic) NSArray *requestBodyParameterList;
@property (nonatomic, strong) NSString *reqestBodyJSONString;

@end

@implementation PNLiteDemoRequestInspectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urlParameterList = [self parseURLStringAndPopulateParameters:[PNLiteRequestInspector sharedInstance].lastInspectedRequest.url];
    
    if([PNLiteRequestInspector sharedInstance].lastInspectedRequest.reqestBody == nil) {
        self.requestTextConstraint.constant = 100;
        self.requestBodyTextConstraint.constant = 40;
        
        self.viewRequestBodyButton.enabled = NO;
        self.jsonRequestBodyButton.enabled = NO;
        self.requestBodyTextView.text = @"To view the request body data, simply click on the 'View Request Body' button. Please note that for APIv3 requests, there is no body as they are GET requests.";
    } else {
        self.requestTextConstraint.constant = 40;
        self.requestBodyTextConstraint.constant = 100;
        
        self.requestBodyParameterList = [self parseRequestBodyAndPopulateParameters:[PNLiteRequestInspector sharedInstance].lastInspectedRequest.reqestBody];
        self.reqestBodyJSONString = [[NSString alloc] initWithData:[PNLiteRequestInspector sharedInstance].lastInspectedRequest.reqestBody encoding:NSUTF8StringEncoding];
        self.requestBodyTextView.text = self.reqestBodyJSONString;
    }
    
    self.navigationItem.title = @"Request Inspector";
    self.requestTextView.text = [PNLiteRequestInspector sharedInstance].lastInspectedRequest.url;
    self.latencyTextView.text = [NSString stringWithFormat:@"%@",[PNLiteRequestInspector sharedInstance].lastInspectedRequest.latency];
    self.responseTextView.text = [PNLiteRequestInspector sharedInstance].lastInspectedRequest.response;
}

- (void)viewDidLayoutSubviews {
    [self.requestTextView setContentOffset:CGPointZero animated:NO];
    [self.latencyTextView setContentOffset:CGPointZero animated:NO];
    [self.responseTextView setContentOffset:CGPointZero animated:NO];
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)copyRequestBody:(UIButton *)sender {
    // Show alert controller
        [self showAlertControllerWithText:self.reqestBodyJSONString];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.requestBodyTextView.text;
    
}

- (IBAction)copyAdReponse:(id)sender {
    // Show alert controller
    [self showAlertControllerWithText:@"Ad response copied"];
    // Copy text
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.responseTextView.text;
}

- (void)showAlertControllerWithText:(NSString *)text {
    // Create and show alert controller
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];

    [self presentViewController:alertController animated:YES completion:nil];
    // Dismiss alert controller after 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)navigateToRequestInspectorDetailViewController:(UIButton *)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"RequestInspector" bundle:nil];
    PNLiteDemoRequestInspectorDetailViewController* requestTableViewController = [sb instantiateViewControllerWithIdentifier:@"PNLiteDemoRequestInspectorDetailViewController"];
    
    if ([sender.accessibilityIdentifier isEqualToString:@"requestUrlBtn"]) {
        requestTableViewController.receivedData = self.urlParameterList;
    } else if ([sender.accessibilityIdentifier isEqualToString:@"viewRequestBodyBtn"]) {
        requestTableViewController.receivedData = self.requestBodyParameterList;
    }
    
    [self presentViewController:requestTableViewController animated:YES completion:nil];
}

- (NSArray<NSDictionary *> *)parseURLStringAndPopulateParameters:(NSString *)urlString {
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
    NSMutableArray<NSDictionary *> *parameterList = [NSMutableArray array];

    for (NSURLQueryItem *queryItem in queryItems) {
        NSString *parameterKey = queryItem.name;
        NSString *parameterValue = queryItem.value;
        NSDictionary *parameterInfo = @{@"parameterKey": parameterKey, @"parameterValue": parameterValue};
        [parameterList addObject:parameterInfo];
    }

    return [self sortParameters:parameterList];
}

- (NSArray<NSDictionary *> *)parseRequestBodyAndPopulateParameters:(NSData *)bodyData {
    NSError *error;
    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:&error];

    if (error) {
        NSLog(@"Failed to convert body data to dictionary: %@", error);
        return nil;
    }

    NSMutableArray<NSDictionary *> *parameterList = [NSMutableArray array];
    [self flattenDictionary:body intoArray:parameterList withKeyPrefix:nil];

    return [self sortParameters:parameterList];
}

- (void)flattenDictionary:(NSDictionary *)dict intoArray:(NSMutableArray *)array withKeyPrefix:(NSString *)prefix {
    for (NSString *key in dict) {
        id value = dict[key];
        NSString *newKey = prefix ? [NSString stringWithFormat:@"%@.%@", prefix, key] : key;
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            [self flattenDictionary:value intoArray:array withKeyPrefix:newKey];
        } else if ([value isKindOfClass:[NSArray class]]) {
            [self flattenArray:value intoArray:array withKeyPrefix:newKey];
        } else {
            NSString *parameterValue = [value isKindOfClass:[NSNull class]] ? @"" : [value description];
            NSDictionary *parameterInfo = @{@"parameterKey": newKey, @"parameterValue": parameterValue};
            [array addObject:parameterInfo];
        }
    }
}

- (void)flattenArray:(NSArray *)arr intoArray:(NSMutableArray *)array withKeyPrefix:(NSString *)prefix {
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newKey = [NSString stringWithFormat:@"%@[%lu]", prefix, (unsigned long)idx];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self flattenDictionary:obj intoArray:array withKeyPrefix:newKey];
        } else {
            NSString *parameterValue = [obj isKindOfClass:[NSNull class]] ? @"" : [obj description];
            NSDictionary *parameterInfo = @{@"parameterKey": newKey, @"parameterValue": parameterValue};
            [array addObject:parameterInfo];
        }
    }];
}

- (NSArray<NSDictionary *> *)sortParameters:(NSMutableArray<NSDictionary *> *)parameterList {
    // Set sorting by key [a-z]
    return [parameterList sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dict1, NSDictionary *dict2) {
        NSString *key1 = dict1[@"parameterKey"];
        NSString *key2 = dict2[@"parameterKey"];
        return [key1 localizedCaseInsensitiveCompare:key2];
    }];
}


@end
