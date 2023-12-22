//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
