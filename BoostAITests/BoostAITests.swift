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


    // MARK: - Typing indicator (offline, synthetic messages)

    private func decodeMessage(_ json: String) throws -> APIMessage {
        let decoder = JSONDecoder()
        return try decoder.decode(APIMessage.self, from: json.data(using: .utf8)!)
    }

    func testHumanChatTypingIndicator() throws {
        let backend = ChatBackend()
        backend.domain = "example.boost.ai"

        let vc = ChatViewController(backend: backend)
        vc.startConversationOnLoad = false
        vc.loadViewIfNeeded()

        func rowCount() -> Int { vc.chatStackView.arrangedSubviews.count }

        // 1. Agent message that moves the conversation into human chat.
        let agentMsg = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "assigned_to_human", "poll": true}},
         "response": {"id": "100", "source": "bot", "language": "en-US",
                      "elements": [{"type": "text", "payload": {"text": "Hi, agent here"}}]}}
        """)
        try backend.handleApiMessage(agentMsg)
        vc.handleReceivedMessage(agentMsg, animateElements: false)
        let afterAgent = rowCount()
        print("PROBE rows after agent message:", afterAgent)

        // 2. Poll with NO new responses but human_is_typing = true -> dots must appear.
        let typingPoll = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "assigned_to_human", "poll": true, "human_is_typing": true}}}
        """)
        try backend.handleApiMessage(typingPoll)
        vc.handleReceivedMessage(typingPoll, animateElements: false)
        let afterTypingPoll = rowCount()
        print("PROBE rows after typing poll:", afterTypingPoll, "(expect \(afterAgent + 1))")
        XCTAssertEqual(afterTypingPoll, afterAgent + 1, "typing indicator row should be added")

        // 3. Second identical typing poll -> indicator should remain (exactly one).
        try backend.handleApiMessage(typingPoll)
        vc.handleReceivedMessage(typingPoll, animateElements: false)
        print("PROBE rows after 2nd typing poll:", rowCount(), "(expect \(afterAgent + 1))")
        XCTAssertEqual(rowCount(), afterAgent + 1, "still exactly one typing indicator")

        // 4. Poll carrying a DUPLICATE response and human_is_typing = true
        //    (agent sent a message earlier and is typing the next one).
        let dupTypingPoll = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "assigned_to_human", "poll": true, "human_is_typing": true}},
         "responses": [{"id": "100", "source": "bot", "language": "en-US",
                        "elements": [{"type": "text", "payload": {"text": "Hi, agent here"}}]}]}
        """)
        try backend.handleApiMessage(dupTypingPoll)
        vc.handleReceivedMessage(dupTypingPoll, animateElements: false)
        print("PROBE rows after duplicate+typing poll:", rowCount(), "(expect \(afterAgent + 1))")
        XCTAssertEqual(rowCount(), afterAgent + 1, "duplicate response must not clear the typing indicator while human_is_typing is true")

        // 5. Poll WITHOUT the typing flag and without responses: the indicator mirrors the
        //    flag poll-for-poll (matching the Android SDK), so it is taken down again.
        let quietPoll = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "assigned_to_human", "poll": true}}}
        """)
        try backend.handleApiMessage(quietPoll)
        vc.handleReceivedMessage(quietPoll, animateElements: false)
        print("PROBE rows after quiet poll:", rowCount(), "(expect \(afterAgent): indicator mirrors the flag)")
        XCTAssertEqual(rowCount(), afterAgent, "indicator hidden when a poll carries no typing flag")

        // 6. Typing again, then the agent message arrives -> indicator swapped for the reply.
        try backend.handleApiMessage(typingPoll)
        vc.handleReceivedMessage(typingPoll, animateElements: false)
        XCTAssertEqual(rowCount(), afterAgent + 1, "indicator shown again")

        // 7. Agent message arrives, typing stops -> indicator gone, message row added.
        let agentMsg2 = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "assigned_to_human", "poll": true, "human_is_typing": false}},
         "responses": [{"id": "101", "source": "bot", "language": "en-US",
                        "elements": [{"type": "text", "payload": {"text": "Here is my reply"}}]}]}
        """)
        try backend.handleApiMessage(agentMsg2)
        vc.handleReceivedMessage(agentMsg2, animateElements: false)
        print("PROBE rows after agent reply:", rowCount(), "(expect \(afterAgent + 1), indicator swapped for message)")
        XCTAssertEqual(rowCount(), afterAgent + 1, "indicator removed, reply added")
    }


    func testVirtualAgentTypingIndicator() throws {
        let backend = ChatBackend()
        backend.domain = "example.boost.ai"

        let vc = ChatViewController(backend: backend)
        vc.startConversationOnLoad = false
        vc.loadViewIfNeeded()

        func rowCount() -> Int { vc.chatStackView.arrangedSubviews.count }

        // Welcome message in virtual agent mode.
        let welcome = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "virtual_agent"}},
         "response": {"id": "1", "source": "bot", "language": "en-US",
                      "elements": [{"type": "text", "payload": {"text": "Welcome"}}]}}
        """)
        try backend.handleApiMessage(welcome)
        vc.handleReceivedMessage(welcome, animateElements: false)
        let base = rowCount()

        // Local echo of the user's message (source client, no conversation).
        let echo = try decodeMessage("""
        {"response": {"id": "tmp-1", "source": "client", "language": "en-US",
                      "elements": [{"type": "text", "payload": {"text": "Hello"}}]}}
        """)
        vc.handleReceivedMessage(echo, animateElements: false)
        print("PROBE VA rows after client echo:", rowCount(), "(expect \(base + 2): echo + typing indicator)")
        XCTAssertEqual(rowCount(), base + 2, "VA mode: indicator must appear after a client message")

        // VA reply arrives -> indicator swapped for the reply.
        let reply = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "virtual_agent"}},
         "response": {"id": "2", "source": "bot", "language": "en-US",
                      "elements": [{"type": "text", "payload": {"text": "Answer"}}]}}
        """)
        try backend.handleApiMessage(reply)
        vc.handleReceivedMessage(reply, animateElements: false)
        print("PROBE VA rows after reply:", rowCount(), "(expect \(base + 2): echo + reply, no indicator)")
        XCTAssertEqual(rowCount(), base + 2, "VA mode: indicator removed when the reply arrives")
    }


    private func findActionLinkViews(in view: UIView) -> [ActionLinkView] {
        var found: [ActionLinkView] = []
        for subview in view.subviews {
            if let linkView = subview as? ActionLinkView {
                found.append(linkView)
            }
            found.append(contentsOf: findActionLinkViews(in: subview))
        }
        return found
    }

    func testActionLinkGroupSettlesWhenRequestSucceeds() throws {
        URLProtocol.registerClass(ChatAPIStubProtocol.self)
        defer { URLProtocol.unregisterClass(ChatAPIStubProtocol.self) }
        ChatAPIStubProtocol.reset()

        let backend = ChatBackend()
        backend.domain = ChatAPIStubProtocol.host

        let vc = ChatViewController(backend: backend)
        vc.startConversationOnLoad = false
        vc.loadViewIfNeeded()

        let linksMsg = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "virtual_agent"}},
         "response": {"id": "10", "source": "bot", "language": "en-US",
                      "elements": [{"type": "links", "payload": {"links": [
                          {"id": "L1", "text": "Option A", "type": "action_link"},
                          {"id": "L2", "text": "Option B", "type": "action_link"},
                          {"id": "L3", "text": "Read more", "type": "external_link", "url": "https://example.com"}]}}]}}
        """)
        try backend.handleApiMessage(linksMsg)
        vc.handleReceivedMessage(linksMsg, animateElements: false)

        guard let responseView = vc.chatStackView.arrangedSubviews.last as? ChatResponseView else {
            XCTFail("no response view rendered"); return
        }
        let linkViews = findActionLinkViews(in: responseView)
        XCTAssertEqual(linkViews.count, 3, "all links rendered")
        let actionLinks = Array(linkViews[0...1])
        let externalLink = linkViews[2]

        let tapped = actionLinks[0]
        let recognizer = tapped.gestureRecognizers!.compactMap { $0 as? UITapGestureRecognizer }.first!
        responseView.didTapActionLink(sender: recognizer)

        XCTAssertTrue(actionLinks.allSatisfy { !$0.isUserInteractionEnabled },
                      "action links disabled while the request is pending")

        // The request succeeds through the stubbed API; the group settles on completion.
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline && tapped.layer.opacity != 1 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTAssertEqual(tapped.layer.opacity, 1, "chosen link reads as selected")
        XCTAssertEqual(actionLinks[1].layer.opacity, 0.5, "sibling stays dimmed")
        XCTAssertTrue(actionLinks.allSatisfy { !$0.isUserInteractionEnabled },
                      "settled group is not tappable")
        XCTAssertTrue(externalLink.isUserInteractionEnabled,
                      "external link stays tappable in a settled group")
        XCTAssertEqual(externalLink.layer.opacity, 1, "external link stays undimmed")

        // Not even the retry reopen may unsettle an answered group.
        vc.reopenActionLinksForRetry()
        XCTAssertTrue(actionLinks.allSatisfy { !$0.isUserInteractionEnabled },
                      "settled group stays locked through the retry reopen")
    }

    func testActionLinkGroupStaysPendingThroughUnrelatedMessagesAndReopensOnError() throws {
        let backend = ChatBackend()
        backend.domain = "example.boost.ai"

        let vc = ChatViewController(backend: backend)
        vc.startConversationOnLoad = false
        vc.loadViewIfNeeded()

        let linksMsg = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "virtual_agent"}},
         "response": {"id": "20", "source": "bot", "language": "en-US",
                      "elements": [{"type": "links", "payload": {"links": [
                          {"id": "L1", "text": "Option A", "type": "action_link"},
                          {"id": "L2", "text": "Option B", "type": "action_link"}]}}]}}
        """)
        try backend.handleApiMessage(linksMsg)
        vc.handleReceivedMessage(linksMsg, animateElements: false)

        guard let responseView = vc.chatStackView.arrangedSubviews.last as? ChatResponseView else {
            XCTFail("no response view rendered"); return
        }
        let linkViews = findActionLinkViews(in: responseView)
        let tapped = linkViews[0]
        let recognizer = tapped.gestureRecognizers!.compactMap { $0 as? UITapGestureRecognizer }.first!
        responseView.didTapActionLink(sender: recognizer)
        XCTAssertTrue(linkViews.allSatisfy { !$0.isUserInteractionEnabled })

        // An unrelated message (a poll tick, a local echo, an ack) arriving while the
        // request is pending must neither settle the group nor reopen it.
        let unrelated = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "virtual_agent"}},
         "response": {"id": "21", "source": "bot", "language": "en-US",
                      "elements": [{"type": "text", "payload": {"text": "Unrelated"}}]}}
        """)
        try backend.handleApiMessage(unrelated)
        vc.handleReceivedMessage(unrelated, animateElements: false)

        XCTAssertTrue(linkViews.allSatisfy { !$0.isUserInteractionEnabled },
                      "pending group stays disabled through unrelated messages")
        XCTAssertEqual(tapped.layer.opacity, 0.5, "pending group is not settled by unrelated messages")

        // The request fails: the error path reopens the group so the user can retry.
        vc.reopenActionLinksForRetry()
        XCTAssertTrue(linkViews.allSatisfy { $0.isUserInteractionEnabled },
                      "group reopens for retry after an error")
        XCTAssertTrue(linkViews.allSatisfy { $0.layer.opacity == 1 },
                      "reopened links look enabled again")
    }


    func testTappingNonWebExternalLinkDoesNotCrash() throws {
        let backend = ChatBackend()
        backend.domain = "example.boost.ai"

        let vc = ChatViewController(backend: backend)
        vc.startConversationOnLoad = false
        vc.loadViewIfNeeded()

        // mailto: and scheme-less URLs used to reach SFSafariViewController(url:), which
        // raises NSInvalidArgumentException for anything that is not http/https.
        let linksMsg = try decodeMessage("""
        {"conversation": {"id": "c1", "state": {"chat_status": "virtual_agent"}},
         "response": {"id": "30", "source": "bot", "language": "en-US",
                      "elements": [{"type": "links", "payload": {"links": [
                          {"id": "L1", "text": "Mail us", "type": "external_link", "url": "mailto:test@example.com"},
                          {"id": "L2", "text": "Bare link", "type": "external_link", "url": "www.example.com"}]}}]}}
        """)
        try backend.handleApiMessage(linksMsg)
        vc.handleReceivedMessage(linksMsg, animateElements: false)

        guard let responseView = vc.chatStackView.arrangedSubviews.last as? ChatResponseView else {
            XCTFail("no response view rendered"); return
        }
        let linkViews = findActionLinkViews(in: responseView)
        XCTAssertEqual(linkViews.count, 2)

        for linkView in linkViews {
            let recognizer = linkView.gestureRecognizers!.compactMap { $0 as? UITapGestureRecognizer }.first!
            responseView.didTapActionLink(sender: recognizer)
        }

        // Reaching this line at all is the regression test: both taps used to crash.
        XCTAssertTrue(linkViews.allSatisfy { $0.isUserInteractionEnabled },
                      "external links stay tappable after being tapped")
    }

    func testSingleton() throws {
        let chatBackend = ChatBackend.shared
        XCTAssert(chatBackend === ChatBackend.shared)
    }
    
    func testMessageObserver() throws {
        let chatBackend = ChatBackend.shared
        chatBackend.addMessageObserver(self) {
                message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
        }
    }

}
