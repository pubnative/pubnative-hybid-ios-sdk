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

#import <Foundation/Foundation.h>

#import "PNLiteConfiguration.h"
#import "PNLiteMetaData.h"

static NSString *_Nonnull const PNLite_SeverityError = @"error";
static NSString *_Nonnull const PNLite_SeverityWarning = @"warning";
static NSString *_Nonnull const PNLite_SeverityInfo = @"info";

@interface PNLiteCrashTracker : NSObject

/** Get the current PNLite configuration.
 *
 * This method returns nil if called before +startPNLiteCrashTrackerWithApiKey: or
 * +startPNLiteCrashTrackerWithConfiguration:, and otherwise returns the current
 * configuration for PNLite.
 *
 * @return The configuration, or nil.
 */
+ (PNLiteConfiguration *_Nullable)configuration;

/** Start listening for crashes.
 *
 * This method initializes PNLite with the default configuration. Any uncaught
 * NSExceptions, C++ exceptions, mach exceptions or signals will be logged to
 * disk before your app crashes. The next time your app boots, we send any such
 * reports to PNLite.
 *
 * @param apiKey  The API key from your PNLite dashboard.
 */
+ (void)startPNLiteCrashTrackerWithApiKey:(NSString *_Nonnull)apiKey;

/** Start listening for crashes.
 *
 * This method initializes PNLite. Any uncaught NSExceptions, uncaught
 * C++ exceptions, mach exceptions or signals will be logged to disk before
 * your app crashes. The next time your app boots, we send any such
 * reports to PNLite.
 *
 * @param configuration  The configuration to use.
 */
+ (void)startPNLiteCrashTrackerWithConfiguration:
    (PNLiteConfiguration *_Nonnull)configuration;

/** Send a custom or caught exception to PNLite.
 *
 * The exception will be sent to PNLite in the background allowing your
 * app to continue running.
 *
 * @param exception  The exception.
 */
+ (void)notify:(NSException *_Nonnull)exception;

/**
 *  Send a custom or caught exception to PNLite
 *
 *  @param exception The exception
 *  @param block     A block for optionally configuring the error report
 */
+ (void)notify:(NSException *_Nonnull)exception
         block:(PNLiteNotifyBlock _Nullable)block;

/**
 *  Send an error to PNLite
 *
 *  @param error The error
 */
+ (void)notifyError:(NSError *_Nonnull)error;

/**
 *  Send an error to PNLite
 *
 *  @param error The error
 *  @param block A block for optionally configuring the error report
 */
+ (void)notifyError:(NSError *_Nonnull)error
              block:(PNLiteNotifyBlock _Nullable)block;

/** Send a custom or caught exception to PNLite.
 *
 * The exception will be sent to PNLite in the background allowing your
 * app to continue running.
 *
 * @param exception  The exception.
 *
 * @param metaData   Any additional information you want to send with the
 * report.
 */
+ (void)notify:(NSException *_Nonnull)exception
      withData:(NSDictionary *_Nullable)metaData
    __deprecated_msg("Use notify:block: instead and add the metadata to the "
                     "report directly.");

/** Send a custom or caught exception to PNLite.
 *
 * The exception will be sent to PNLite in the background allowing your
 * app to continue running.
 *
 * @param exception  The exception.
 *
 * @param metaData   Any additional information you want to send with the
 * report.
 *
 * @param severity   The severity level (default: PNLite_SeverityWarning)
 */
+ (void)notify:(NSException *_Nonnull)exception
      withData:(NSDictionary *_Nullable)metaData
    atSeverity:(NSString *_Nullable)severity
    __deprecated_msg("Use notify:block: instead and add the metadata and "
                     "severity to the report directly.");

/**
 * Intended for use by other clients (React Native/Unity). Calling this method
 * directly from iOS is not supported.
 */
+ (void)internalClientNotify:(NSException *_Nonnull)exception
                    withData:(NSDictionary *_Nullable)metaData
                       block:(PNLiteNotifyBlock _Nullable)block;

/** Add custom data to send to PNLite with every exception. If value is nil,
 *  delete the current value for attributeName
 *
 * See also [PNLite configuration].metaData;
 *
 * @param attributeName  The name of the data.
 *
 * @param value          Its value.
 *
 * @param tabName        The tab to show it on on the PNLite dashboard.
 */
+ (void)addAttribute:(NSString *_Nonnull)attributeName
           withValue:(id _Nullable)value
       toTabWithName:(NSString *_Nonnull)tabName;

/** Remove custom data from PNLite reports.
 *
 * @param tabName        The tab to clear.
 */
+ (void)clearTabWithName:(NSString *_Nonnull)tabName;

/**
 * Leave a "breadcrumb" log message, representing an action that occurred
 * in your app, to aid with debugging.
 *
 * @param message  the log message to leave (max 140 chars)
 */
+ (void)leaveBreadcrumbWithMessage:(NSString *_Nonnull)message;

/**
 *  Leave a "breadcrumb" log message with additional information about the
 *  environment at the time the breadcrumb was captured.
 *
 *  @param block configuration block
 */
+ (void)leaveBreadcrumbWithBlock:
    (void (^_Nonnull)(PNLiteBreadcrumb *_Nonnull))block;

/**
 *  Leave a "breadcrumb" log message each time a notification with a provided
 *  name is received by the application
 *
 *  @param notificationName name of the notification to capture
 */
+ (void)leaveBreadcrumbForNotificationName:(NSString *_Nonnull)notificationName;

/**
 * Set the maximum number of breadcrumbs to keep and sent to PNLite.
 * By default, we'll keep and send the 20 most recent breadcrumb log
 * messages.
 *
 * @param capacity max number of breadcrumb log messages to send
 */
+ (void)setBreadcrumbCapacity:(NSUInteger)capacity;

/**
 * Clear any breadcrumbs that have been left so far.
 */
+ (void)clearBreadcrumbs;

+ (NSDateFormatter *_Nonnull)payloadDateFormatter;

+ (void)setSuspendThreadsForUserReported:(BOOL)suspendThreadsForUserReported;
+ (void)setReportWhenDebuggerIsAttached:(BOOL)reportWhenDebuggerIsAttached;
+ (void)setThreadTracingEnabled:(BOOL)threadTracingEnabled;
+ (void)setWriteBinaryImagesForUserReported:
    (BOOL)writeBinaryImagesForUserReported;

/**
 * Manually starts tracking a new session.
 *
 * Sessions automatically start when the application enters the foreground state, and end when the application exits
 * the foreground.If you wish to manually start sessions, simply call this method from the relevant part of your
 * application. Starting a new session will automatically end the previous one.
 */

+ (void)startSession;

@end
