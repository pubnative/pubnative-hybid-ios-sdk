// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
    NSString *mraidjs = [self loadJavaScriptFile:@"hybidmraidscaling" fromBundle:bundle];
    NSString *omjs = [self loadJavaScriptFile:@"omsdk" fromBundle:bundle];
    NSString *scalingjs = [self loadJavaScriptFile:@"hybidscaling" fromBundle:bundle];
    
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

    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:processedHtml options:0 range:NSMakeRange(0, [processedHtml length])];

    for (NSTextCheckingResult* match in matches) {
        NSRange matchRange = [match rangeAtIndex:0];
        NSString *replacementString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@", metaTag, styleTag, mraidjs, omjs, scalingjs];
        processedHtml = [processedHtml stringByReplacingCharactersInRange:matchRange withString:replacementString];
        break;
    }
    
    return processedHtml;
}

+ (NSString *) loadJavaScriptFile:(NSString *) fileName fromBundle:(NSBundle*) bundle {
    if (bundle && fileName && ![fileName isEqualToString:@""]) {
        NSString *filePath = [bundle pathForResource:fileName ofType:@"js"];
        if (filePath) {
            NSError *error = nil;
            NSString *javascript = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            if (!error) {
                return [NSString stringWithFormat:@"<script>\n%@\n</script>", javascript];
            }
        }
    }
    return @"";
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
