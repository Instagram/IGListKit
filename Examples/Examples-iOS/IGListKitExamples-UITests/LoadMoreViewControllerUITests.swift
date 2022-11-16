/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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
