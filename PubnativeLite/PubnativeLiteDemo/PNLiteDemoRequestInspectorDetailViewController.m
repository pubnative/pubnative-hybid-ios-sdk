// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoRequestInspectorDetailViewController.h"

@interface PNLiteDemoRequestInspectorDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *requestTableView;

@end

@implementation PNLiteDemoRequestInspectorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requestTableView.dataSource = self;
    self.requestTableView.delegate = self;

    [self.requestTableView reloadData];
}

- (IBAction)dismissButtonTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receivedData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HyBidRequestInspectorDebugCell"];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HyBidRequestInspectorDebugCell"];
    }

    NSDictionary *parameterInfo = self.receivedData[indexPath.row];

    cell.textLabel.text = parameterInfo[@"parameterKey"];
    cell.detailTextLabel.text = parameterInfo[@"parameterValue"];

    // Set accessibility identifiers for the title and detail elements
    cell.textLabel.accessibilityIdentifier = [NSString stringWithFormat:@"CellTitle%@", parameterInfo[@"parameterKey"]];
    cell.detailTextLabel.accessibilityIdentifier = [NSString stringWithFormat:@"CellDetail%@", parameterInfo[@"parameterKey"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSDictionary *parameterInfo = self.receivedData[indexPath.row];
    NSString *value = parameterInfo[@"parameterValue"];
    
    [pasteboard setString:value];
    
    NSAttributedString *formattedMessage = [self formatMessageText:value];
    
    [self showAlertWithMessage:formattedMessage];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSAttributedString *)formatMessageText:(NSString *)message {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:[message stringByReplacingOccurrencesOfString:@"," withString:@",\n"] attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
    
    return attributedMessage;
}

- (void)showAlertWithMessage:(NSAttributedString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Copied to Clipboard" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController setValue:message forKey:@"attributedMessage"];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
