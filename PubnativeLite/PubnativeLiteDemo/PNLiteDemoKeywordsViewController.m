// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoKeywordsViewController.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoKeywordsViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *allKeywordsTextView;
@property (weak, nonatomic) IBOutlet UITextField *keywordTextField;
@property (nonatomic, strong) NSString *newlyAddedKeyword;

@end

@implementation PNLiteDemoKeywordsViewController

- (void)dealloc {
    self.newlyAddedKeyword = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Keywords";
    self.allKeywordsTextView.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoKeywordsKey];
}

- (IBAction)handleTap:(UIGestureRecognizer *)recognizer {
    if (!([self.keywordTextField.text length] > 0)) {
        self.keywordTextField.text = nil;
        [self.keywordTextField resignFirstResponder];
    }
}

- (IBAction)addKeywordTouchUpInside:(UIButton *)sender {
    [self.keywordTextField resignFirstResponder];
    if ([self.newlyAddedKeyword length] > 0) {
        if ([self.allKeywordsTextView.text length] > 0) {
            self.allKeywordsTextView.text = [self.allKeywordsTextView.text stringByAppendingString:[NSString stringWithFormat:@",%@",self.newlyAddedKeyword]];
        } else {
        self.allKeywordsTextView.text = [self.allKeywordsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@",self.newlyAddedKeyword]];
        }
        self.newlyAddedKeyword = nil;
    }
}

- (IBAction)clearKeywordsTouchUpInside:(UIButton *)sender {
    self.allKeywordsTextView.text = @"";
}

- (IBAction)saveKeywordsTouchUpInside:(UIButton *)sender {
    if ([self.allKeywordsTextView.text length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.allKeywordsTextView.text forKey:kHyBidDemoKeywordsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kHyBidDemoKeywordsKey];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    self.newlyAddedKeyword = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

@end
