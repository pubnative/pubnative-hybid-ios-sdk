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

#ifndef HDR_PNLite_KSCrashReportFields_h
#define HDR_PNLite_KSCrashReportFields_h

#pragma mark - Report Types -

#define PNLite_KSCrashReportType_Minimal "minimal"
#define PNLite_KSCrashReportType_Standard "standard"
#define PNLite_KSCrashReportType_Custom "custom"

#pragma mark - Memory Types -

#define PNLite_KSCrashMemType_Block "objc_block"
#define PNLite_KSCrashMemType_Class "objc_class"
#define PNLite_KSCrashMemType_NullPointer "null_pointer"
#define PNLite_KSCrashMemType_Object "objc_object"
#define PNLite_KSCrashMemType_String "string"
#define PNLite_KSCrashMemType_Unknown "unknown"

#pragma mark - Exception Types -

#define PNLite_KSCrashExcType_CPPException "cpp_exception"
#define PNLite_KSCrashExcType_Deadlock "deadlock"
#define PNLite_KSCrashExcType_Mach "mach"
#define PNLite_KSCrashExcType_NSException "nsexception"
#define PNLite_KSCrashExcType_Signal "signal"
#define PNLite_KSCrashExcType_User "user"

#pragma mark - Common -

#define PNLite_KSCrashField_Address "address"
#define PNLite_KSCrashField_Contents "contents"
#define PNLite_KSCrashField_Exception "exception"
#define PNLite_KSCrashField_FirstObject "first_object"
#define PNLite_KSCrashField_Index "index"
#define PNLite_KSCrashField_Ivars "ivars"
#define PNLite_KSCrashField_Language "language"
#define PNLite_KSCrashField_Name "name"
#define PNLite_KSCrashField_ReferencedObject "referenced_object"
#define PNLite_KSCrashField_Type "type"
#define PNLite_KSCrashField_UUID "uuid"
#define PNLite_KSCrashField_Value "value"

#define PNLite_KSCrashField_Error "error"
#define PNLite_KSCrashField_JSONData "json_data"

#pragma mark - Notable Address -

#define PNLite_KSCrashField_Class "class"
#define PNLite_KSCrashField_LastDeallocObject "last_deallocated_obj"

#pragma mark - Backtrace -

#define PNLite_KSCrashField_InstructionAddr "instruction_addr"
#define PNLite_KSCrashField_LineOfCode "line_of_code"
#define PNLite_KSCrashField_ObjectAddr "object_addr"
#define PNLite_KSCrashField_ObjectName "object_name"
#define PNLite_KSCrashField_SymbolAddr "symbol_addr"
#define PNLite_KSCrashField_SymbolName "symbol_name"

#pragma mark - Stack Dump -

#define PNLite_KSCrashField_DumpEnd "dump_end"
#define PNLite_KSCrashField_DumpStart "dump_start"
#define PNLite_KSCrashField_GrowDirection "grow_direction"
#define PNLite_KSCrashField_Overflow "overflow"
#define PNLite_KSCrashField_StackPtr "stack_pointer"

#pragma mark - Thread Dump -

#define PNLite_KSCrashField_Backtrace "backtrace"
#define PNLite_KSCrashField_Basic "basic"
#define PNLite_KSCrashField_Crashed "crashed"
#define PNLite_KSCrashField_CurrentThread "current_thread"
#define PNLite_KSCrashField_DispatchQueue "dispatch_queue"
#define PNLite_KSCrashField_NotableAddresses "notable_addresses"
#define PNLite_KSCrashField_Registers "registers"
#define PNLite_KSCrashField_Skipped "skipped"
#define PNLite_KSCrashField_Stack "stack"

#pragma mark - Binary Image -

#define PNLite_KSCrashField_CPUSubType "cpu_subtype"
#define PNLite_KSCrashField_CPUType "cpu_type"
#define PNLite_KSCrashField_ImageAddress "image_addr"
#define PNLite_KSCrashField_ImageVmAddress "image_vmaddr"
#define PNLite_KSCrashField_ImageSize "image_size"

#pragma mark - Memory -

#define PNLite_KSCrashField_Free "free"
#define PNLite_KSCrashField_Usable "usable"

#pragma mark - Error -

#define PNLite_KSCrashField_Backtrace "backtrace"
#define PNLite_KSCrashField_Code "code"
#define PNLite_KSCrashField_CodeName "code_name"
#define PNLite_KSCrashField_CPPException "cpp_exception"
#define PNLite_KSCrashField_ExceptionName "exception_name"
#define PNLite_KSCrashField_Mach "mach"
#define PNLite_KSCrashField_NSException "nsexception"
#define PNLite_KSCrashField_Reason "reason"
#define PNLite_KSCrashField_Signal "signal"
#define PNLite_KSCrashField_Subcode "subcode"
#define PNLite_KSCrashField_UserReported "user_reported"

#pragma mark - Process State -

#define PNLite_KSCrashField_LastDeallocedNSException "last_dealloced_nsexception"
#define PNLite_KSCrashField_ProcessState "process"

#pragma mark - App Stats -

#define PNLite_KSCrashField_ActiveTimeSinceCrash "active_time_since_last_crash"
#define PNLite_KSCrashField_ActiveTimeSinceLaunch "active_time_since_launch"
#define PNLite_KSCrashField_AppActive "application_active"
#define PNLite_KSCrashField_AppInFG "application_in_foreground"
#define PNLite_KSCrashField_BGTimeSinceCrash "background_time_since_last_crash"
#define PNLite_KSCrashField_BGTimeSinceLaunch "background_time_since_launch"
#define PNLite_KSCrashField_LaunchesSinceCrash "launches_since_last_crash"
#define PNLite_KSCrashField_SessionsSinceCrash "sessions_since_last_crash"
#define PNLite_KSCrashField_SessionsSinceLaunch "sessions_since_launch"

#pragma mark - Report -

#define PNLite_KSCrashField_Crash "crash"
#define PNLite_KSCrashField_Diagnosis "diagnosis"
#define PNLite_KSCrashField_ID "id"
#define PNLite_KSCrashField_ProcessName "process_name"
#define PNLite_KSCrashField_Report "report"
#define PNLite_KSCrashField_Timestamp "timestamp"
#define PNLite_KSCrashField_Version "version"

#pragma mark Minimal
#define PNLite_KSCrashField_CrashedThread "crashed_thread"

#pragma mark Standard
#define PNLite_KSCrashField_AppStats "application_stats"
#define PNLite_KSCrashField_BinaryImages "binary_images"
#define PNLite_KSCrashField_SystemAtCrash "system_atcrash"
#define PNLite_KSCrashField_System "system"
#define PNLite_KSCrashField_Memory "memory"
#define PNLite_KSCrashField_Threads "threads"
#define PNLite_KSCrashField_User "user"
#define PNLite_KSCrashField_UserAtCrash "user_atcrash"

#pragma mark Incomplete
#define PNLite_KSCrashField_Incomplete "incomplete"
#define PNLite_KSCrashField_RecrashReport "recrash_report"

#endif
