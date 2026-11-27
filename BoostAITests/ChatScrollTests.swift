//
//  ChatScrollTests.swift
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

/// A new message must bring the conversation to the end — unless its newest element is taller
/// than the visible area, which must then be shown from its top.
final class ChatScrollTests: XCTestCase {

    private var window: UIWindow!

    override func tearDown() {
        window = nil
        super.tearDown()
    }

    private func makeController() -> ChatViewController {
        let vc = ChatViewController(backend: ChatBackend())
        vc.startConversationOnLoad = false

        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 700))
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.view.layoutIfNeeded()

        // Enough history that the conversation overflows the screen
        for _ in 0..<6 {
            vc.chatStackView.addArrangedSubview(fixedHeightView(200))
        }
        return vc
    }

    private func fixedHeightView(_ height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }

    private func addResponse(to vc: ChatViewController, elements: [UIView]) {
        let responseView = ChatResponseView(backend: vc.backend)
        responseView.addElementViews(elements, animated: false)
        vc.chatStackView.addArrangedSubview(responseView)
    }

    func testAShortElementScrollsToTheEnd() {
        let vc = makeController()
        addResponse(to: vc, elements: [fixedHeightView(40), fixedHeightView(60)])

        vc.scrollToEnd(animated: false)

        let scrollView = vc.scrollView!
        XCTAssertEqual(
            scrollView.contentOffset.y,
            scrollView.contentSize.height - scrollView.bounds.height,
            accuracy: 1
        )
    }

    /// A tall element, such as a carousel above an open keyboard, must not be scrolled past:
    /// its top (the image and title) has to stay in view.
    func testATallElementIsShownFromItsTop() {
        let vc = makeController()
        let tall = fixedHeightView(2000)
        addResponse(to: vc, elements: [fixedHeightView(40), tall])

        vc.scrollToEnd(animated: false)

        let scrollView = vc.scrollView!
        let topInView = tall.convert(tall.bounds, to: scrollView).minY - scrollView.contentOffset.y
        XCTAssertGreaterThanOrEqual(topInView, 0, "the top of the tall element was scrolled out of view")
        XCTAssertLessThanOrEqual(topInView, 20, "scrolled short of the tall element's top")
    }
}
