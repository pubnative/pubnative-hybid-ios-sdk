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

#ifndef PNLiteKeys_h
#define PNLiteKeys_h

#import <Foundation/Foundation.h>

static NSString *const PNLiteDefaultNotifyUrl = @"https://notify.bugsnag.com/";

static NSString *const PNLiteKeyException = @"exception";
static NSString *const PNLiteKeyMessage = @"message";
static NSString *const PNLiteKeyName = @"name";
static NSString *const PNLiteKeyTimestamp = @"timestamp";
static NSString *const PNLiteKeyType = @"type";
static NSString *const PNLiteKeyMetaData = @"metaData";
static NSString *const PNLiteKeyId = @"id";
static NSString *const PNLiteKeyUser = @"user";
static NSString *const PNLiteKeyEmail = @"email";
static NSString *const PNLiteKeyDevelopment = @"development";
static NSString *const PNLiteKeyProduction = @"production";
static NSString *const PNLiteKeyReleaseStage = @"releaseStage";
static NSString *const PNLiteKeyConfig = @"config";
static NSString *const PNLiteKeyContext = @"context";
static NSString *const PNLiteKeyAppVersion = @"appVersion";
static NSString *const PNLiteKeyNotifyReleaseStages = @"notifyReleaseStages";
static NSString *const PNLiteKeyApiKey = @"apiKey";
static NSString *const PNLiteKeyNotifier = @"notifier";
static NSString *const PNLiteKeyEvents = @"events";
static NSString *const PNLiteKeyVersion = @"version";
static NSString *const PNLiteKeySeverity = @"severity";
static NSString *const PNLiteKeyUrl = @"url";
static NSString *const PNLiteKeyBatteryLevel = @"batteryLevel";
static NSString *const PNLiteKeyDeviceState = @"deviceState";
static NSString *const PNLiteKeyCharging = @"charging";
static NSString *const PNLiteKeyLabel = @"label";
static NSString *const PNLiteKeySeverityReason = @"severityReason";
static NSString *const PNLiteKeyLogLevel = @"logLevel";
static NSString *const PNLiteKeyOrientation = @"orientation";
static NSString *const PNLiteKeySimulatorModelId = @"SIMULATOR_MODEL_IDENTIFIER";
static NSString *const PNLiteKeyFrameAddrFormat = @"0x%lx";
static NSString *const PNLiteKeySymbolAddr = @"symbolAddress";
static NSString *const PNLiteKeyMachoLoadAddr = @"machoLoadAddress";
static NSString *const PNLiteKeyIsPC = @"isPC";
static NSString *const PNLiteKeyIsLR = @"isLR";
static NSString *const PNLiteKeyMachoFile = @"machoFile";
static NSString *const PNLiteKeyMachoUUID = @"machoUUID";
static NSString *const PNLiteKeyMachoVMAddress = @"machoVMAddress";
static NSString *const PNLiteKeyCppException = @"cpp_exception";
static NSString *const PNLiteKeyExceptionName = @"exception_name";
static NSString *const PNLiteKeyMach = @"mach";
static NSString *const PNLiteKeySignal = @"signal";
static NSString *const PNLiteKeyReason = @"reason";
static NSString *const PNLiteKeyInfo = @"info";
static NSString *const PNLiteKeyWarning = @"warning";
static NSString *const PNLiteKeyError = @"error";
static NSString *const PNLiteKeyOsVersion = @"osVersion";
static NSString *const PNLiteKeySystem = @"system";
static NSString *const PNLiteKeyStacktrace = @"stacktrace";
static NSString *const PNLiteKeyGroupingHash = @"groupingHash";
static NSString *const PNLiteKeyErrorClass = @"errorClass";
static NSString *const PNLiteKeyBreadcrumbs = @"breadcrumbs";
static NSString *const PNLiteKeyThreads = @"threads";
static NSString *const PNLiteKeyExceptions = @"exceptions";
static NSString *const PNLiteKeyPayloadVersion = @"payloadVersion";
static NSString *const PNLiteKeyDevice = @"device";
static NSString *const PNLiteKeyAppState = @"app";
static NSString *const PNLiteKeyApp = @"app";
static NSString *const PNLiteKeyUnhandled = @"unhandled";
static NSString *const PNLiteKeyAttributes = @"attributes";
static NSString *const PNLiteKeyAction = @"action";
static NSString *const PNLiteKeySession = @"session";


static NSString *const PNLiteKeyExecutableName = @"CFBundleExecutable";
static NSString *const PNLiteKeyHwModel = @"hw.model";
static NSString *const PNLiteKeyHwMachine = @"hw.machine";

#define PNLiteKeyHwCputype "hw.cputype"
#define PNLiteKeyHwCpusubtype "hw.cpusubtype"
#define PNLiteKeyDefaultMacName "en0"

#endif /* PNLiteKeys_h */
