//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

import XCTest
import Foundation
@testable import HyBid

final class HyBidLoggerTests: XCTestCase {
    
    func testAtomLog_whenLogLevelIsATOM_printsClassMethodAndMessage() {
        HyBidLogger.setLogLevel(HyBidLogLevelATOM)
        
        let output = captureStdout {
            HyBidLogger.atomLog(
                fromClass: "HyBidLoggerTests",
                fromMethod: "testAtomLog_whenLogLevelIsATOM_printsClassMethodAndMessage",
                withMessage: "ATOM test message"
            )
        }
        
        XCTAssertEqual(
            output,
            """
            
             ----------------------- 
             [LOG TYPE]: Debug
             [CLASS]: HyBidLoggerTests
             [METHOD]: testAtomLog_whenLogLevelIsATOM_printsClassMethodAndMessage 
             [withMessage]: ATOM test message
             -----------------------
            
            """
        )
    }
    
    func testAtomLog_whenLogLevelIsBelowATOM_doesNotPrintAnything() {
        HyBidLogger.setLogLevel(HyBidLogLevelDebug)

        let output = captureStdout {
            HyBidLogger.atomLog(
                fromClass: "HyBidLoggerTests",
                fromMethod: "testAtomLog_whenLogLevelIsBelowATOM_doesNotPrintAnything",
                withMessage: "ATOM test message"
            )
        }

        XCTAssertTrue(output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: - setLogLevel tests

    func test_setLogLevel_setsLogLevelProperty() {
        HyBidLogger.setLogLevel(HyBidLogLevelError)
        XCTAssertEqual(HyBidLogger.logLevel, HyBidLogLevelError)
    }

    func test_setLogLevel_printedOutputContainsLevelName() {
        let output = captureStdout {
            HyBidLogger.setLogLevel(HyBidLogLevelWarning)
        }
        XCTAssertTrue(output.contains("Warning"), "Expected 'Warning' in output: \(output)")
    }

    func test_setLogLevel_toDebug_printedOutputContainsDebug() {
        let output = captureStdout {
            HyBidLogger.setLogLevel(HyBidLogLevelDebug)
        }
        XCTAssertTrue(output.contains("Debug"), "Expected 'Debug' in output: \(output)")
    }

    func test_setLogLevel_toInfo_printedOutputContainsInfo() {
        let output = captureStdout {
            HyBidLogger.setLogLevel(HyBidLogLevelInfo)
        }
        XCTAssertTrue(output.contains("Info"), "Expected 'Info' in output: \(output)")
    }

    // MARK: - errorLog tests

    func test_errorLog_whenLogLevelIsError_printsOutput() {
        HyBidLogger.setLogLevel(HyBidLogLevelError)
        let output = captureStdout {
            HyBidLogger.errorLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "error msg")
        }
        XCTAssertTrue(output.contains("[LOG TYPE]: Error"), "Expected error log output, got: \(output)")
    }

    func test_errorLog_whenLogLevelIsInfo_printsOutput() {
        // Info >= Error, so errorLog should still fire
        HyBidLogger.setLogLevel(HyBidLogLevelInfo)
        let output = captureStdout {
            HyBidLogger.errorLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "error msg")
        }
        XCTAssertTrue(output.contains("[LOG TYPE]: Error"))
    }

    // MARK: - warningLog tests

    func test_warningLog_whenLogLevelIsWarning_printsOutput() {
        HyBidLogger.setLogLevel(HyBidLogLevelWarning)
        let output = captureStdout {
            HyBidLogger.warningLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "warning msg")
        }
        XCTAssertTrue(output.contains("[LOG TYPE]: Warning"))
    }

    func test_warningLog_whenLogLevelIsError_doesNotPrint() {
        HyBidLogger.setLogLevel(HyBidLogLevelError)
        let output = captureStdout {
            HyBidLogger.warningLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "warning msg")
        }
        XCTAssertTrue(output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: - infoLog tests

    func test_infoLog_whenLogLevelIsInfo_printsOutput() {
        HyBidLogger.setLogLevel(HyBidLogLevelInfo)
        let output = captureStdout {
            HyBidLogger.infoLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "info msg")
        }
        XCTAssertTrue(output.contains("[LOG TYPE]: Info"))
    }

    func test_infoLog_whenLogLevelIsWarning_doesNotPrint() {
        // Warning < Info, so infoLog should be filtered
        HyBidLogger.setLogLevel(HyBidLogLevelWarning)
        let output = captureStdout {
            HyBidLogger.infoLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "info msg")
        }
        XCTAssertTrue(output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: - debugLog tests

    func test_debugLog_whenLogLevelIsDebug_printsOutput() {
        HyBidLogger.setLogLevel(HyBidLogLevelDebug)
        let output = captureStdout {
            HyBidLogger.debugLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "debug msg")
        }
        // debugLog falls through to default case in internalLog → "Debug"
        XCTAssertTrue(output.contains("[LOG TYPE]: Debug"))
    }

    func test_debugLog_whenLogLevelIsInfo_doesNotPrint() {
        // Info < Debug, so debugLog should be filtered
        HyBidLogger.setLogLevel(HyBidLogLevelInfo)
        let output = captureStdout {
            HyBidLogger.debugLog(fromClass: "TestClass", fromMethod: "testMethod", withMessage: "debug msg")
        }
        XCTAssertTrue(output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // MARK: - internalLog switch case tests

    func test_internalLog_withErrorLevel_containsErrorType() {
        HyBidLogger.setLogLevel(HyBidLogLevelDebug)
        let output = captureStdout {
            HyBidLogger.internalLog(fromClass: "C", fromMethod: "M", withMessage: "msg", logLevel: HyBidLogLevelError)
        }
        XCTAssertTrue(output.contains("[LOG TYPE]: Error"))
    }

    func test_internalLog_withInfoLevel_containsInfoType() {
        HyBidLogger.setLogLevel(HyBidLogLevelDebug)
        let output = captureStdout {
            HyBidLogger.internalLog(fromClass: "C", fromMethod: "M", withMessage: "msg", logLevel: HyBidLogLevelInfo)
        }
        XCTAssertTrue(output.contains("[LOG TYPE]: Info"))
    }

    func test_internalLog_withWarningLevel_containsWarningType() {
        HyBidLogger.setLogLevel(HyBidLogLevelDebug)
        let output = captureStdout {
            HyBidLogger.internalLog(fromClass: "C", fromMethod: "M", withMessage: "msg", logLevel: HyBidLogLevelWarning)
        }
        XCTAssertTrue(output.contains("[LOG TYPE]: Warning"))
    }

    func test_internalLog_withDebugLevel_containsDebugType() {
        HyBidLogger.setLogLevel(HyBidLogLevelDebug)
        let output = captureStdout {
            HyBidLogger.internalLog(fromClass: "C", fromMethod: "M", withMessage: "msg", logLevel: HyBidLogLevelDebug)
        }
        // HyBidLogLevelDebug hits `default` case → "Debug"
        XCTAssertTrue(output.contains("[LOG TYPE]: Debug"))
    }

    func test_log_outputContainsClassName() {
        HyBidLogger.setLogLevel(HyBidLogLevelError)
        let output = captureStdout {
            HyBidLogger.errorLog(fromClass: "MySpecialClass", fromMethod: "myMethod", withMessage: "msg")
        }
        XCTAssertTrue(output.contains("[CLASS]: MySpecialClass"))
    }

    func test_log_outputContainsMethodName() {
        HyBidLogger.setLogLevel(HyBidLogLevelError)
        let output = captureStdout {
            HyBidLogger.errorLog(fromClass: "C", fromMethod: "mySpecialMethod", withMessage: "msg")
        }
        XCTAssertTrue(output.contains("[METHOD]: mySpecialMethod"))
    }

    func test_log_outputContainsMessage() {
        HyBidLogger.setLogLevel(HyBidLogLevelError)
        let output = captureStdout {
            HyBidLogger.errorLog(fromClass: "C", fromMethod: "M", withMessage: "uniqueTestMessage123")
        }
        XCTAssertTrue(output.contains("[withMessage]: uniqueTestMessage123"))
    }

    // MARK: - setUp / tearDown (restore log level)

    override func setUp() {
        super.setUp()
        HyBidLogger.setLogLevel(HyBidLogLevelInfo) // restore default before each test
    }

    // MARK: Helpers
    
    private func captureStdout(_ block: () -> Void) -> String {
        fflush(stdout)
        
        let pipe = Pipe()
        let originalStdout = dup(STDOUT_FILENO)
        
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        block()
        
        fflush(stdout)
        dup2(originalStdout, STDOUT_FILENO)
        close(originalStdout)
        
        pipe.fileHandleForWriting.closeFile()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        pipe.fileHandleForReading.closeFile()
        
        return String(data: data, encoding: .utf8) ?? ""
    }
}
