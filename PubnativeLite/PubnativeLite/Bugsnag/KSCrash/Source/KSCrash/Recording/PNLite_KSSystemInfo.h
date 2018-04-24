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

#define PNLite_KSSystemField_AppStartTime "app_start_time"
#define PNLite_KSSystemField_AppUUID "app_uuid"
#define PNLite_KSSystemField_BootTime "boot_time"
#define PNLite_KSSystemField_BundleID "CFBundleIdentifier"
#define PNLite_KSSystemField_BundleName "CFBundleName"
#define PNLite_KSSystemField_BundleShortVersion "CFBundleShortVersionString"
#define PNLite_KSSystemField_BundleVersion "CFBundleVersion"
#define PNLite_KSSystemField_CPUArch "cpu_arch"
#define PNLite_KSSystemField_CPUType "cpu_type"
#define PNLite_KSSystemField_CPUSubType "cpu_subtype"
#define PNLite_KSSystemField_BinaryCPUType "binary_cpu_type"
#define PNLite_KSSystemField_BinaryCPUSubType "binary_cpu_subtype"
#define PNLite_KSSystemField_DeviceAppHash "device_app_hash"
#define PNLite_KSSystemField_Executable "CFBundleExecutable"
#define PNLite_KSSystemField_ExecutablePath "CFBundleExecutablePath"
#define PNLite_KSSystemField_Jailbroken "jailbroken"
#define PNLite_KSSystemField_KernelVersion "kernel_version"
#define PNLite_KSSystemField_Machine "machine"
#define PNLite_KSSystemField_Memory "memory"
#define PNLite_KSSystemField_Model "model"
#define PNLite_KSSystemField_OSVersion "os_version"
#define PNLite_KSSystemField_ParentProcessID "parent_process_id"
#define PNLite_KSSystemField_ProcessID "process_id"
#define PNLite_KSSystemField_ProcessName "process_name"
#define PNLite_KSSystemField_Size "size"
#define PNLite_KSSystemField_SystemName "system_name"
#define PNLite_KSSystemField_SystemVersion "system_version"
#define PNLite_KSSystemField_TimeZone "time_zone"
#define PNLite_KSSystemField_BuildType "build_type"

#import <Foundation/Foundation.h>

/**
 * Provides system information useful for a crash report.
 */
@interface PNLite_KSSystemInfo : NSObject

/** Get the system info.
 *
 * @return The system info.
 */
+ (NSDictionary *)systemInfo;

@end
