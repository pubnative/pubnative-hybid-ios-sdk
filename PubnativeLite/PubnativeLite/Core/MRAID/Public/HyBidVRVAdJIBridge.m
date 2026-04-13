//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVRVAdJIBridge.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

@implementation HyBidVRVAdJIBridge

+ (void)injectIntoController:(WKUserContentController *)controller {
    #if __has_include(<ATOM/ATOM-Swift.h>)
    // Pre-load ALL ATOM data from UserDefaults (atomvalue_* keys)
    // This allows ad response to call VRVAdJI.getAtomJsData("any_key") dynamically
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *allDefaults = [defaults dictionaryRepresentation];
    NSMutableDictionary *atomDataStore = [NSMutableDictionary dictionary];

    // Scan for all ATOM keys (stored with ATOM_KEY_PREFIX prefix)
    NSString *atomKeyPrefix = HyBidConstants.ATOM_KEY_PREFIX;
    for (NSString *key in allDefaults.allKeys) {
        if ([key hasPrefix:atomKeyPrefix]) {
            NSString *actualKey = [key substringFromIndex:atomKeyPrefix.length];
            id value = allDefaults[key];

            // Convert value to string for JavaScript compatibility
            if ([value isKindOfClass:[NSString class]]) {
                atomDataStore[actualKey] = value;
            } else if ([value isKindOfClass:[NSNumber class]]) {
                atomDataStore[actualKey] = [value stringValue];
            } else if (value) {
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
                if (!error && jsonData) {
                    atomDataStore[actualKey] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
            }
        }
    }

    // Convert dictionary to JSON for embedding in JavaScript
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:atomDataStore options:0 error:&error];
    NSString *atomDataStoreJSON = @"{}";

    if (!error && jsonData) {
        atomDataStoreJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        // Escape </script> tags to prevent breaking JavaScript parsing when embedded in <script> tag
        // Replace </script> with <\/script> (if not already escaped) or <\\/script>
        atomDataStoreJSON = [atomDataStoreJSON stringByReplacingOccurrencesOfString:@"</script>" withString:@"<\\/script>"];
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class])
                            fromMethod:NSStringFromSelector(_cmd)
                           withMessage:[NSString stringWithFormat:@"Failed to serialize ATOM data: %@", error.localizedDescription]];
    }

    // Create JavaScript injection that defines VRVAdJI global object
    NSString *vrjviJavaScript = [NSString stringWithFormat:@
        "window.VRVAdJI = (function() {"
        "    'use strict';"
        "    "
        "    var atomDataStore = %@;"
        "    function forwardSurveyData(payload) {"
        "        if (!window.webkit || !window.webkit.messageHandlers || !window.webkit.messageHandlers.onSurveyDataCollected) {"
        "            console.warn('[VRVAdJI] onSurveyDataCollected handler is not available');"
        "            return;"
        "        }"
        "        var valueToSend = payload;"
        "        if (typeof payload === 'object' && payload !== null) {"
        "            try {"
        "                valueToSend = JSON.stringify(payload);"
        "            } catch (e) {"
        "                valueToSend = String(payload);"
        "            }"
        "        }"
        "        window.webkit.messageHandlers.onSurveyDataCollected.postMessage(valueToSend);"
        "    }"
        "    "
        "    return {"
        "        getAtomJsData: function(key) {"
        "            "
        "            if (!key || typeof key !== 'string') {"
        "                console.error('[VRVAdJI] Invalid key provided:', key);"
        "                return null;"
        "            }"
        "            "
        "            var data = atomDataStore[key];"
        "            "
        "            if (data === undefined || data === null) {"
        "                console.warn('[VRVAdJI] No data found for key:', key);"
        "                return null;"
        "            }"
        "            "
        "            if (typeof data === 'string') {"
        "                try {"
        "                    var parsed = JSON.parse(data);"
        "                    return parsed;"
        "                } catch(e) {"
        "                    return data;"
        "                }"
        "            }"
        "            "
        "            return data;"
        "        },"
        "        onSurveyDataCollected: function(payload) {"
        "            forwardSurveyData(payload);"
        "        }"
        "    };"
        "})();"
        ""
    , atomDataStoreJSON];

    // Inject at document start (before any HTML content executes)
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:vrjviJavaScript
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                   forMainFrameOnly:YES];
    [controller addUserScript:userScript];
    #endif
}

@end
