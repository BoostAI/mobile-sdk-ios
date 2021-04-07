//
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

class MessagesTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_response_from_consent() throws {
        let json = """
{"conversation":{"id":"nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==","state":{"allow_delete_conversation":true,"chat_status":"virtual_agent","max_input_chars":110,"privacy_policy_url":"https://www.boost.ai/privacy-policy"}},"response":{"avatar_url":"https://master.boost.ai/img/james.png","date_created":"2020-06-25T07:10:43.184456","elements":[{"payload":{"html":"<p>Flott, hvordan kan jeg hjelpe deg?</p>"},"type":"html"}],"id":"1683979","language":"no-NO","source":"bot"}}
"""
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let formatter = DateFormatter.iso8601Full
        decoder.dateDecodingStrategy = .formatted(formatter)
        let responsePage: APIMessage = try! decoder.decode(APIMessage.self, from: jsonData)
        XCTAssertEqual(responsePage.conversation!.id, "nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==")
        XCTAssertEqual(responsePage.conversation!.state.allowDeleteConversation, true)
        XCTAssertEqual(responsePage.conversation!.state.chatStatus, ChatStatus.virtual_agent)
        XCTAssertEqual(responsePage.conversation!.state.maxInputChars, 110)
        XCTAssertEqual(responsePage.conversation!.state.privacyPolicyUrl, "https://www.boost.ai/privacy-policy")
        XCTAssertEqual(responsePage.response!.avatarUrl, "https://master.boost.ai/img/james.png")
        XCTAssertEqual(formatter.string(from: responsePage.response!.dateCreated!),"2020-06-25T07:10:43.184")
        XCTAssertEqual(responsePage.response!.elements[0].payload.html, "<p>Flott, hvordan kan jeg hjelpe deg?</p>")
        XCTAssertEqual(responsePage.response!.id, "1683979")
        XCTAssertEqual(responsePage.response!.language, "no-NO")
        XCTAssertEqual(responsePage.response!.source, SourceType.bot)
    }
    
    func test_question_response() throws {
        let json = """
{"conversation":{"id":"nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==","state":{"allow_delete_conversation":true,"chat_status":"virtual_agent","max_input_chars":110,"privacy_policy_url":"https://www.boost.ai/privacy-policy"}},"posted_id":1683980,"response":{"avatar_url":"https://master.boost.ai/img/james.png","date_created":"2020-06-25T10:05:33.433153","elements":[{"payload":{"html":"<p>Hva lurer du p\u{00e5}?</p>\\n"},"type":"html"}],"id":"1683981","language":"no-NO","source":"bot"}}

"""
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let formatter = DateFormatter.iso8601Full
        decoder.dateDecodingStrategy = .formatted(formatter)
        let responsePage: APIMessage = try! decoder.decode(APIMessage.self, from: jsonData)
        XCTAssertEqual(responsePage.conversation!.id, "nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==")
        XCTAssertEqual(responsePage.conversation!.state.allowDeleteConversation, true)
        XCTAssertEqual(responsePage.conversation!.state.chatStatus, ChatStatus.virtual_agent)
        XCTAssertEqual(responsePage.conversation!.state.maxInputChars, 110)
        XCTAssertEqual(responsePage.conversation!.state.privacyPolicyUrl, "https://www.boost.ai/privacy-policy")
        XCTAssertEqual(responsePage.response!.avatarUrl, "https://master.boost.ai/img/james.png")
        XCTAssertEqual(formatter.string(from: responsePage.response!.dateCreated!),"2020-06-25T10:05:33.433")
        XCTAssertEqual(responsePage.response!.elements[0].payload.html, "<p>Hva lurer du p\u{00e5}?</p>\n")
        XCTAssertEqual(responsePage.response!.id, "1683981")
        XCTAssertEqual(responsePage.response!.language, "no-NO")
        XCTAssertEqual(responsePage.response!.source, SourceType.bot)
        XCTAssertEqual(responsePage.postedId, 1683980)
    }
    
    func test_question_response_2() throws {
        let json = """
{"conversation":{"id":"nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==","state":{"allow_delete_conversation":true,"chat_status":"virtual_agent","max_input_chars":110,"privacy_policy_url":"https://www.boost.ai/privacy-policy"}},"posted_id":1683982,"response":{"avatar_url":"https://master.boost.ai/img/james.png","date_created":"2020-06-25T10:50:22.703025","elements":[{"payload":{"html":"<p>Jeg forst\u{00e5}r dessverre ikke sp\u{00f8}rsm\u{00e5}let ditt.</p>"},"type":"html"},{"payload":{"html":"<p>Vil du at jeg skal sette deg over til en av mine menneskelige kollegaer?</p>"},"type":"html"},{"payload":{"links":[{"id":"184712","text":"Ja","type":"action_link"},{"id":"184713","text":"Nei","type":"action_link"}]},"type":"links"}],"id":"1683983","language":"no-NO","source":"bot"}}

"""
        
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let formatter = DateFormatter.iso8601Full
        decoder.dateDecodingStrategy = .formatted(formatter)
        let responsePage: APIMessage = try! decoder.decode(APIMessage.self, from: jsonData)
        XCTAssertEqual(responsePage.conversation!.id, "nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==")
        XCTAssertEqual(responsePage.conversation!.state.allowDeleteConversation, true)
        XCTAssertEqual(responsePage.conversation!.state.chatStatus, ChatStatus.virtual_agent)
        XCTAssertEqual(responsePage.conversation!.state.maxInputChars, 110)
        XCTAssertEqual(responsePage.conversation!.state.privacyPolicyUrl, "https://www.boost.ai/privacy-policy")
        XCTAssertEqual(responsePage.response!.avatarUrl, "https://master.boost.ai/img/james.png")
        XCTAssertEqual(formatter.string(from: responsePage.response!.dateCreated!),"2020-06-25T10:50:22.703")
        XCTAssertEqual(responsePage.response!.elements[0].payload.html, "<p>Jeg forst\u{00e5}r dessverre ikke sp\u{00f8}rsm\u{00e5}let ditt.</p>")
        XCTAssertEqual(responsePage.response!.elements[0].type, ElementType.html)
        XCTAssertEqual(responsePage.response!.elements[1].payload.html, "<p>Vil du at jeg skal sette deg over til en av mine menneskelige kollegaer?</p>")
        XCTAssertEqual(responsePage.response!.elements[1].type, ElementType.html)
        XCTAssertEqual(responsePage.response!.elements[2].type, ElementType.links)
        XCTAssertEqual(responsePage.response!.elements[2].payload.links![0].id, "184712")
        XCTAssertEqual(responsePage.response!.elements[2].payload.links![0].text, "Ja")
        XCTAssertEqual(responsePage.response!.elements[2].payload.links![0].type, LinkType.action_link)
        XCTAssertEqual(responsePage.response!.elements[2].payload.links![1].id, "184713")
        XCTAssertEqual(responsePage.response!.elements[2].payload.links![1].text, "Nei")
        XCTAssertEqual(responsePage.response!.elements[2].payload.links![1].type, LinkType.action_link)
        XCTAssertEqual(responsePage.response!.id, "1683983")
        XCTAssertEqual(responsePage.response!.language, "no-NO")
        XCTAssertEqual(responsePage.response!.source, SourceType.bot)
        XCTAssertEqual(responsePage.postedId, 1683982)
    }
    
    func test_stop_response() throws {
    let json = """
{"conversation":{"id":"L77So5LYQcZ8mPnZf5rdbkEkaBarKe9-LoYhSZIeUchY7_Zvt4bnw08wMvUZGhkzxKLF7SjU0r71xa5hfhDF4Q==","reference":"98cef0ca2b7687f519f52e2e83179b4b","state":{"allow_delete_conversation":true,"chat_status":"virtual_agent","is_blocked":true,"max_input_chars":110,"privacy_policy_url":"https://www.boost.ai/privacy-policy"}}}
"""
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let formatter = DateFormatter.iso8601Full
        decoder.dateDecodingStrategy = .formatted(formatter)
        let responsePage: APIMessage = try! decoder.decode(APIMessage.self, from: jsonData)
        XCTAssertEqual(responsePage.conversation!.id, "L77So5LYQcZ8mPnZf5rdbkEkaBarKe9-LoYhSZIeUchY7_Zvt4bnw08wMvUZGhkzxKLF7SjU0r71xa5hfhDF4Q==")
    }
    
    func testZ_payload_json_response() throws {
        let json = """
    {"conversation":{"id":"nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==","state":{"allow_delete_conversation":true,"chat_status":"virtual_agent","max_input_chars":110,"privacy_policy_url":"https://www.boost.ai/privacy-policy"}},"posted_id":1683982,"response":{"avatar_url":"https://master.boost.ai/img/james.png","date_created":"2020-06-25T10:50:22.703025","elements":[{"payload":{"json":{"test": "1", "sub": {"testing": 1}}},"type":"json"}],"id":"1683983","language":"no-NO","source":"bot"}}

    """
            let jsonData = json.data(using: .utf8)!
            let decoder = JSONDecoder()
            let formatter = DateFormatter.iso8601Full
            decoder.dateDecodingStrategy = .formatted(formatter)
            let responsePage: APIMessage = try! decoder.decode(APIMessage.self, from: jsonData)
        let payload = responsePage.response?.elements[0].payload.json

        print(String(decoding: payload!, as: UTF8.self))
            XCTAssertEqual(responsePage.conversation!.id, "nxa5G6sKHNdLNla2LMZcjHOmwwRrQqs9D1nDddtwYyX1KSMCHKC9-lzQIZ1RYcX9W04nkNUVPwaYvHgT7vPmZw==")
        }
}
