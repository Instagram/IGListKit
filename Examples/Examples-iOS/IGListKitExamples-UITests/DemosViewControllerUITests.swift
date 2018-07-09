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

final class DemosViewControllerUITests: UITestCase {

    func test_whenSelectingTailLoading_thatTailLoadingDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Tail Loading")
    }

    func test_whenSelectingSearchAutocomplete_thatSearchAutocompleteDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Search Autocomplete")
    }

    func test_whenSelectingMixedData_thatMixedDataDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Mixed Data")
    }

    func test_whenSelectingNestedAdapter_thatNestedAdapterDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Nested Adapter")
    }

    func test_whenSelectingEmptyView_thatEmptyViewDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Empty View")
    }

    func test_whenSelectingSingleSectionController_thatSingleSectionControllerScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Single Section Controller")
    }

    func test_whenSelectingStoryboard_thatStoryboardDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Storyboard")
    }

    func test_whenSelectingSingleSectionStoryboard_thatSingleSectionStoryboardDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Single Section Storyboard")
    }

    func test_whenSelectingWorkingRange_thatWorkingRangeDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Working Range")
    }

    func test_whenSelectingDiffAlgorithm_thatDiffAlgorithmDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Diff Algorithm")
    }

    func test_whenSelectingSupplementaryViews_thatSupplementaryViewsDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Supplementary Views")
    }

    func test_whenSelectingSelfSizingCells_thatSelfSizingCellsDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Self-sizing cells")
    }

    func test_whenSelectingDisplayDelegate_thatDisplayDelegateDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Display delegate")
    }

    private func enterAndAssertScreen(withTitle title: String) {
        let elem = XCUIApplication().collectionViews.cells.staticTexts[title]
        if !elem.exists {
            XCUIApplication().collectionViews.element.swipeUp()
        }

        XCTAssertTrue(elem.exists)
        elem.tap()
        XCTAssertTrue(XCUIApplication().navigationBars[title].exists)
    }
}
