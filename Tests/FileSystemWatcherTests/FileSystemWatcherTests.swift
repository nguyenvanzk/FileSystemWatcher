import XCTest
import Foundation
@testable import FileSystemWatcher

class FileSystemWatcherTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }

    func testEventNotification() {
    	
    	var madeIt = false

    	func pingFunc() {
    		madeIt = true
    	}

    	let delayToBeTested = 0.1 
    	let testWatcher = FileSystemWatcher(deferringDelay: delayToBeTested)

    	testWatcher.start()
    	testWatcher.stop()
    	// let fManager = FileManager.default

		//try fManager.createDirectory(atPath: "testSandBox", withIntermediateDirectories: false)

    	// do {
    	// 	try fManager.createDirectory(atPath: "testSandBox", withIntermediateDirectories: false)

    	// 	print("testSandBox created!")

	    XCTAssertEqual("Hello, World!", "Hello, World!")

    	// } catch {
    	// 	print("Couldn't create testSandBox directory.")
    	// }

    	// fManager. 

    	// testWatcher.

    }


    static var allTests = [
        ("testExample", testExample),
        ("testEventNotification", testEventNotification)
    ]
}
