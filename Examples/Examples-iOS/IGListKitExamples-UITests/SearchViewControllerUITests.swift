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
