/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest

class UITestCase: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
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
