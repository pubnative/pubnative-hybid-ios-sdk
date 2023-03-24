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

#import "HyBidVASTHTMLResource.h"
#import "UIKit/UIKit.h"

@interface HyBidVASTHTMLResource ()

@property (nonatomic, strong)HyBidXMLElementEx *htmlResourceXMLElement;

@end

@implementation HyBidVASTHTMLResource

- (instancetype)initWithHTMLResourceXMLElement:(HyBidXMLElementEx *)htmlResourceXMLElement
{
    if (htmlResourceXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.htmlResourceXMLElement = htmlResourceXMLElement;
    }
    return self;
}

- (NSString *)content
{
    NSString *htmlResourceString = [self.htmlResourceXMLElement value];
    NSError *error = nil;
    
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) };
    
    NSString *html = [[NSAttributedString alloc] initWithData:[htmlResourceString dataUsingEncoding:NSUTF8StringEncoding]
                                                      options:options
                                           documentAttributes:nil
                                                        error:&error].string;
    
    // Handle any errors that occurred during conversion
    if (error) {
        return [self.htmlResourceXMLElement value];
    } else {
        
        // Define a regular expression pattern to match any string that contains only occurrences of \U0000fffc and/or occurrences of the newline character \n
        NSString *pattern = @"^([\\n\\U0000fffc]+)$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        
        if (!match && html.length > 0) {
            return html;
        } else {
            return [self.htmlResourceXMLElement value];
        }
    }
    
}

@end
