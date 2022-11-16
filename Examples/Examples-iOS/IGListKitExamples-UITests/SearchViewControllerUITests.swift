/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import XCTest

final class SearchViewControllerUITests: UITestCase {

    var collectionViews: XCUIElementQuery!

    override func setUp() {
        super.setUp()

        collectionViews = XCUIApplication().collectionViews
        collectionViews.cells.staticTexts["Search Autocomplete"].tap()
    }

    func test_whenLoading_thatSomeResultsAreShown() {
        let tacos = collectionViews.cells.staticTexts["tacos"]
        let small = collectionViews.cells.staticTexts["small"]
        XCTAssertTrue(tacos.exists)
        XCTAssertTrue(small.exists)
    }

    func test_whenSearchingForText_thatResultsGetFiltered() {
        let searchField = collectionViews.searchFields.element
        searchField.tap()
        searchField.typeText("tac")

        let tacos = collectionViews.cells.staticTexts["tacos"]
        let small = collectionViews.cells.staticTexts["small"]
        XCTAssertTrue(tacos.exists)
        XCTAssertFalse(small.exists)
    }

    func test_whenClearingText_thatResultsFilterIsRemoved() {
        let searchField = collectionViews.searchFields.element
        searchField.tap()
        searchField.typeText("tac")
        searchField.buttons.element.tap()

        let tacos = collectionViews.cells.staticTexts["tacos"]
        let small = collectionViews.cells.staticTexts["small"]
        XCTAssertTrue(tacos.exists)
        XCTAssertTrue(small.exists)
    }
}
