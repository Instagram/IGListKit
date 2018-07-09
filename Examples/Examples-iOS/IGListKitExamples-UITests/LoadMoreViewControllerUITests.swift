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

final class LoadMoreViewControllerUITests: UITestCase {

    func test_whenScrollingToTheBottom_thatNewItemsAreLoaded() {
        let collectionViews = XCUIApplication().collectionViews
        collectionViews.cells.staticTexts["Tail Loading"].tap()

        // Swipe up until the last element before loading new data is visible
        let lastElem = collectionViews.cells.staticTexts["20"]
        while !lastElem.exists || !XCUIApplication().windows.element(boundBy: 0).frame.contains(lastElem.frame) {
            collectionViews.element.swipeUp()
        }

        // Wait for item "21" to be loaded asynchronously
        let newlyLoadedElement = collectionViews.cells.staticTexts["21"]
        waitToAppear(element: newlyLoadedElement)
    }

}
