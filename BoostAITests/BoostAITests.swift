//
//  BoostAITests.swift
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

class BoostAITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSingleton() throws {
        let chatBackend = ChatBackend.shared
        XCTAssert(chatBackend === ChatBackend.shared)
    }
    
    func testMessageObserver() throws {
        let chatBackend = ChatBackend.shared
        chatBackend.newMessageObserver(self) {
                message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
        }
    }

}
