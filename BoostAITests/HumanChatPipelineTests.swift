//
//  HumanChatPipelineTests.swift
//  BoostAITests
//
//  Copyright © 2026 boost.ai
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

/// Stubs the chat API at the URL-loading layer so the full pipeline — command encoding,
/// networking, decoding, `handleApiMessage`, the poll timer, publishing, and the UI — runs
/// exactly as in production, offline.
final class ChatAPIStubProtocol: URLProtocol {
    static let host = "stub.boost.test"

    /// Commands the stub has served, in order.
    static var servedCommands: [String] = []

    /// Set by the test to control what POLL responds with.
    static var pollResponseJSON: String = ""

    static func reset() {
        servedCommands = []
        pollResponseJSON = ""
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.host == host
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    private func requestBody() -> Data {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return Data() }

        stream.open()
        defer { stream.close() }

        var data = Data()
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            guard read > 0 else { break }
            data.append(buffer, count: read)
        }

        return data
    }

    override func startLoading() {
        let url = request.url!
        let bodyJSON = (try? JSONSerialization.jsonObject(with: requestBody())) as? [String: Any]
        let command = (bodyJSON?["command"] as? String) ?? (url.path.contains("chat_panel") ? "CONFIG" : "?")

        Self.servedCommands.append(command)

        let responseJSON: String
        switch command {
        case "CONFIG":
            responseJSON = "{}"
        case "START":
            responseJSON = """
            {"conversation": {"id": "conv-1", "reference": "ref-1",
                              "state": {"chat_status": "assigned_to_human", "poll": true,
                                        "max_input_chars": 110, "allow_delete_conversation": false}},
             "response": {"id": "1", "source": "bot", "language": "en-US", "date_created": "2026-08-17T10:00:00.000",
                          "elements": [{"type": "text", "payload": {"text": "You are talking to an agent"}}]}}
            """
        case "POLL":
            responseJSON = Self.pollResponseJSON
        default:
            responseJSON = """
            {"conversation": {"id": "conv-1",
                              "state": {"chat_status": "virtual_agent"}}}
            """
        }

        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1",
                                           headerFields: ["Content-Type": "application/json"])!

        client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: responseJSON.data(using: .utf8)!)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

class HumanChatPipelineTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(ChatAPIStubProtocol.self)
        ChatAPIStubProtocol.reset()
    }

    override func tearDown() {
        URLProtocol.unregisterClass(ChatAPIStubProtocol.self)
        super.tearDown()
    }

    /// End-to-end: START moves the conversation into human chat; the poll timer fires; a POLL
    /// response with `human_is_typing: true` must surface the typing indicator row in the UI.
    func testTypingDotsAppearThroughTheRealPipeline() throws {
        ChatAPIStubProtocol.pollResponseJSON = """
        {"conversation": {"id": "conv-1",
                          "state": {"chat_status": "assigned_to_human", "poll": true, "human_is_typing": true}},
         "responses": []}
        """

        let backend = ChatBackend()
        backend.domain = ChatAPIStubProtocol.host
        backend.pollInterval = 0.2

        let vc = ChatViewController(backend: backend)
        vc.startConversationOnLoad = false
        vc.loadViewIfNeeded()

        vc.start()

        // Give the pipeline time for CONFIG + START + at least two poll ticks.
        let deadline = Date().addingTimeInterval(4)
        while Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))

            let hasStartRow = vc.chatStackView.arrangedSubviews.count >= 1
            let hasTypingRow = vc.chatStackView.arrangedSubviews.count >= 2
            if hasStartRow && hasTypingRow && ChatAPIStubProtocol.servedCommands.contains("POLL") {
                break
            }
        }

        print("PROBE served commands:", ChatAPIStubProtocol.servedCommands)
        print("PROBE row count:", vc.chatStackView.arrangedSubviews.count)

        XCTAssertTrue(ChatAPIStubProtocol.servedCommands.contains("START"), "START should have been sent")
        XCTAssertTrue(ChatAPIStubProtocol.servedCommands.contains("POLL"), "the poll timer should have fired")
        XCTAssertGreaterThanOrEqual(vc.chatStackView.arrangedSubviews.count, 2,
                                    "welcome row + typing indicator row expected")

        backend.stopPolling()
    }
}
