// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "UITextField+KeyboardDismiss.h"

@implementation UITextField (KeyboardDismiss)

- (void)addDismissKeyboardButtonWithTitle:(NSString *)title withTarget:(id)target withSelector:(SEL)selector {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
    [toolbar setItems: @[flexibleItem, dismissItem]];
    self.inputAccessoryView = toolbar;
}

@end
