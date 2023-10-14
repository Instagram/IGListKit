/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import XCTest

final class LoadMoreViewControllerUITests: UITestCase {

    func test_whenScrollingToTheBottom_thatNewItemsAreLoaded() {
        let collectionViews = XCUIApplication().collectionViews
        collectionViews.cells.staticTexts["Tail Loading"].tap()

        // Swipe up until the last item in the list is on-screen
        var numberOfTries = 0
        let lastElem = collectionViews.cells.staticTexts["15"]
        while !lastElem.isHittable {
            collectionViews.element.swipeUp()
            numberOfTries += 1
            if numberOfTries >= 10 {
                break
            }
        }

        // Wait for the following item to be loaded asynchronously
        let newlyLoadedElement = collectionViews.cells.staticTexts["16"]
        waitToAppear(element: newlyLoadedElement, timeout: 30.0)
    }

}
