/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import XCTest

class UITestCase: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    // Adapted from http://masilotti.com/xctest-helpers/
    internal func waitToAppear(element: XCUIElement,
                               timeout: TimeInterval = 2,
                               file: String = #file,
                               line: UInt = #line) {
        waitToAppear(elements: [element], timeout: timeout, file: file, line: line)
    }

    internal func waitToAppear(elements: [XCUIElement],
                               timeout: TimeInterval = 2,
                               file: String = #file,
                               line: UInt = #line) {
        waitTo(appear: true, elements: elements, timeout: timeout, file: file, line: line)
    }

    internal func waitToDisappear(element: XCUIElement,
                                  timeout: TimeInterval = 2,
                                  file: String = #file,
                                  line: UInt = #line) {
        waitToDisappear(elements: [element], timeout: timeout, file: file, line: line)
    }

    internal func waitToDisappear(elements: [XCUIElement],
                                  timeout: TimeInterval = 2,
                                  file: String = #file,
                                  line: UInt = #line) {
        waitTo(appear: false, elements: elements, timeout: timeout, file: file, line: line)
    }

    internal func waitTo(appear: Bool,
                         elements: [XCUIElement],
                         timeout: TimeInterval = 2,
                         file: String = #file,
                         line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == \(appear)")
        elements.forEach { element in
            expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        }

        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                let message = "Failed to \(appear ? "" : "not ")find element(s) after \(timeout) seconds."
                self.recordFailure(withDescription: message,
                                   inFile: file,
                                   atLine: Int(line),
                                   expected: true)
            }
        }
    }
}

// MARK: - Helpers added for multiple collection-views (iPad split-view)

private extension XCUIElementQuery {
    /// The list we want to scroll in our UI-tests.
    /// • On iPhone there is only one collection-view, so this is that one.
    /// • On iPad split-view there are two; `firstMatch` is always the master list.
    var primary: XCUIElement { firstMatch }
}

/// Scrolls until `element` is hittable or `maxSwipes` is reached.
internal func scrollToElement(_ element: XCUIElement,
                              in scrollView: XCUIElementQuery = XCUIApplication().collectionViews,
                              maxSwipes: Int = 15) {
    var swipes = 0
    while !element.isHittable && swipes < maxSwipes {
        scrollView.primary.swipeUp()
        swipes += 1
    }
}
