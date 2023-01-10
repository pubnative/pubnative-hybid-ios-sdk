//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "PNLiteMRAIDUtil.h"

@implementation PNLiteMRAIDUtil

+ (NSString *)processRawHtml:(NSString *)rawHtml {
    if (rawHtml == nil) {
        return @"";
    }
    
    NSString *processedHtml = rawHtml;
    
    NSRange range;
    NSError *error = NULL;
    
    //     Remove the mraid.js script tag.
    //     We expect the tag to look like this:
    //     <script src='mraid.js'></script>
    //     But we should also be to handle additional attributes and whitespace like this:
    //     <script  type = 'text/javascript'  src = 'mraid.js' > </script>
    //
    NSString *pattern = @"<script\\s+[^>]*\\bsrc\\s*=\\s*([\\\"\\\'])mraid\\.js\\1[^>]*>\\s*</script>\\n*";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    processedHtml = [regex stringByReplacingMatchesInString:processedHtml
                                                    options:0
                                                      range:NSMakeRange(0, [processedHtml length])
                                               withTemplate:@""];
    
    // Add html, head, and/or body tags as needed.
    range = [[self removeAllScripts:rawHtml] rangeOfString:@"<html"];
    BOOL hasHtmlTag = (range.location != NSNotFound);
    range = [[self removeAllScripts:rawHtml] rangeOfString:@"<head"];
    BOOL hasHeadTag = (range.location != NSNotFound);
    range = [[self removeAllScripts:rawHtml] rangeOfString:@"<body"];
    BOOL hasBodyTag = (range.location != NSNotFound);
    
    // basic sanity checks
    if ((!hasHtmlTag && (hasHeadTag || hasBodyTag)) ||
        (hasHtmlTag && !hasBodyTag)) {
        return nil;
    }
    
    if (!hasHtmlTag) {
        
        if (!hasBodyTag) {
            processedHtml = [NSString stringWithFormat:
                            @"<body>"
                             "<div id='hybid-ad' align='center'>\n"
                             "%@"
                             "</div>"
                             "</body>",
                             processedHtml
            ];
        }
        
        if (!hasHeadTag) {
            processedHtml = [NSString stringWithFormat:
                            @"<head>\n"
                             "</head>\n"
                             "%@",
                             processedHtml
            ];
        }
        
        processedHtml = [NSString stringWithFormat:
                        @"<html>\n"
                         "%@"
                         "</html>",
                         processedHtml
        ];
    } else if (!hasHeadTag) {
        // html tag exists, head tag doesn't, so add it
        pattern = @"<html[^>]*>";
        error = NULL;
        regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
        processedHtml = [regex stringByReplacingMatchesInString:processedHtml
                                                        options:0
                                                          range:NSMakeRange(0, [processedHtml length])
                                                   withTemplate:@"$0\n<head>\n</head>"];
        
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *mraidJSPath = [bundle pathForResource: [self nameForResource:@"hybidmraidscaling" :@"js"] ofType:@"js"];
    NSData *mraidJSData = [NSData dataWithContentsOfFile:mraidJSPath];
    NSString *mraidjs = [[NSString alloc] initWithData:mraidJSData encoding:NSUTF8StringEncoding];
    mraidjs = [NSString stringWithFormat:
                   @"<script>\n"
                    "%@"
                    "\n</script>",
                    mraidjs
    ];
    
    NSString *scalingJSPath = [bundle pathForResource: [self nameForResource:@"hybidscaling" :@"js"] ofType:@"js"];
    NSData *scalingJSData = [NSData dataWithContentsOfFile:scalingJSPath];
    NSString *scalingjs = [[NSString alloc] initWithData:scalingJSData encoding:NSUTF8StringEncoding];
    scalingjs = [NSString stringWithFormat:
                  @"<script>\n"
                   "%@"
                   "\n</script>",
                   scalingjs
    ];
    
    // Add meta and style tags to head tag.
    NSString *metaTag =
    @"<meta name='viewport' content='width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no' />";
    
    NSString *styleTag =
    @"<style>\n"
    "body { margin:0; padding:0; }\n"
    "*:not(input) { -webkit-touch-callout:none; -webkit-user-select:none; -webkit-text-size-adjust:none; }\n"
    "</style>";
    
    pattern = @"<head[^>]*>";
    error = NULL;
    regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];

    
    NSArray<NSTextCheckingResult *> *macthes = [regex matchesInString:processedHtml options:0 range:NSMakeRange(0, [processedHtml length])];
    
    for (NSTextCheckingResult* match in macthes) {
        processedHtml = [regex stringByReplacingMatchesInString:processedHtml
                                                        options:0
                                                          range:match.range
                                                   withTemplate:[NSString stringWithFormat:@"$0\n%@\n%@\n%@\n%@", metaTag, styleTag, mraidjs, scalingjs]];
        break;
    }
    return processedHtml;
}

+ (NSString*) removeAllScripts:(NSString*) htmlString {
    if (htmlString == nil || [htmlString isEqual:@""]) {
        return @"";
    }
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[\\s\\S]*?>[\\s\\S]*?<\\/script>" options:NSRegularExpressionCaseInsensitive error:&error];
    return [regex stringByReplacingMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@""];
}

#pragma mark - Utils: check for bundle resource existance.

+ (NSString*)nameForResource:(NSString*)name :(NSString*)type {
    NSString* resourceName = [NSString stringWithFormat:@"iqv.bundle/%@", name];
    NSString *path = [[NSBundle bundleForClass:[self class]]pathForResource:resourceName ofType:type];
    if (!path) {
        resourceName = name;
    }
    return resourceName;
}

@end
