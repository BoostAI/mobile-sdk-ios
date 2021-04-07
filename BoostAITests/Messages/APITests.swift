//
//  APITests.swift
//  BoostAITests
//
//  Copyright © 2021 boost.ai
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  Please contact us at contact@boost.ai if you have any questions.
//

import XCTest
@testable import BoostAI

class APITests: XCTestCase {
    var backend = ChatBackend.shared
    
    override func setUpWithError() throws {
        backend.domain = "sdk.boost.ai"
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testA_Setup() throws {
        let start = expectation(description: "Waiting for Start command to finish")
        let started = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            
            XCTAssertTrue(true)
            start.fulfill()
        }
        backend.start()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            started.cancel()
        }
    }
    /*
    func testB_Blocked() throws {
        XCTAssertTrue(backend.isBlocked)
    }
    
    func testC_Unblock() throws {
        XCTAssertTrue(backend.isBlocked)
        let unblock = expectation(description: "Waiting for unblocking command to finish")
        let unblocked = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            
            XCTAssertFalse(self.backend.isBlocked)
            unblock.fulfill()
        }
        backend.actionButton(id: backend.lastResponse!.response!.elements[1].payload.links![0].id)
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            unblocked.cancel()
        }
    }
    */
    func testD_clock() throws {
        XCTAssertFalse(backend.isBlocked)
        let lock = expectation(description: "Waiting for clock command to finish")
        var count = 0;
        let locked = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            count += 1
            if (count==2) {
                XCTAssertTrue(message!.response!.elements[0].payload.html!.contains("Klokka er"))
                XCTAssertFalse(self.backend.isBlocked)
                lock.fulfill()
            }
        }
        
        backend.message(value: "Hva er klokken?")
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            locked.cancel()
        }
    }
    
    func testE_text_including_double_quotes() throws {
        XCTAssertFalse(backend.isBlocked)
        let lock = expectation(description: "Waiting for quotes command to finish")
        var count = 0;
        let locked = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            count += 1
            if (count==2) {
                XCTAssertTrue(message!.response!.elements[0].payload.html!.contains("Boost.ai er selskapet"))
                XCTAssertFalse(self.backend.isBlocked)
                lock.fulfill()
            }
        }
        
        backend.message(value: "Hva er \"Boost.ai\"?")
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            locked.cancel()
        }
    }
    
    func testE_text_including_brackets_quotes() throws {
        XCTAssertFalse(backend.isBlocked)
        let lock = expectation(description: "Waiting for brackets command to finish")
        var count = 0;
        let locked = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            count += 1
            if (count==2) {
                XCTAssertFalse(self.backend.isBlocked)
                lock.fulfill()
            }
        }
        
        backend.message(value: "Hva er { svømme?")
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            locked.cancel()
        }
    }
    
    func testF_download() {
        let stop = expectation(description: "Waiting for download command to finish")
        let stopped = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            
            XCTAssertTrue(message!.download!.contains("Boost.ai"))
            stop.fulfill()
        }
        backend.download()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            stopped.cancel()
        }
    }
    
    func testX_Teardown() {
        let stop = expectation(description: "Waiting for Stop command to finish")
        let stopped = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            
            XCTAssertTrue(true)
            stop.fulfill()
        }
        backend.stop()
        //        backend.message(value: "Hva er klokka?")
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            stopped.cancel()
        }
    }
    
    func test_error() {
        let start = expectation(description: "Waiting for Start command to finish")
        let started = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            
            XCTAssertTrue(true)
            start.fulfill()
        }
        backend.start()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            started.cancel()
        }
        
        let feedback = expectation(description: "Waiting for feedback command to finish")
        let feedbacked = backend.newMessageObserver(self) {
            message, error in
            
            if error != nil {
                XCTAssertTrue(true)
            } else {
                XCTFail("No error")
            }
                    
            feedback.fulfill()
        }
        backend.feedback(id: "test", value: .positive)
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            feedbacked.cancel()
        }
    }
}
