/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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

    func test_whenSelectingObjcDemo_thatObjcDemoDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Objc Demo")
    }

    func test_whenSelectingObjcGeneratedModelDemo_thatObjcGeneratedModelDemoDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Objc Generated Model Demo")
    }

    func test_whenSelectingCalendarDemo_thatCalendarDemoDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Calendar (auto diffing)")
    }

    func test_whenSelectingDependencyInjection_thatDependencyInjectionDemoDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Dependency Injection")
    }

    func test_whenSelectingRecorderCells_thatReorderCellsDemoDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Reorder Cells")
    }

    private func enterAndAssertScreen(withTitle title: String) {
        XCUIApplication().activate()
        let elem = XCUIApplication().collectionViews.cells.staticTexts[title]

        var numberOfTries = 0
        while !elem.isHittable {
            XCUIApplication().collectionViews.element.swipeUp()
            numberOfTries += 1
            if numberOfTries >= 10 {
                break
            }
        }

        XCTAssertTrue(elem.exists)
        elem.tap()
        XCTAssertTrue(XCUIApplication().navigationBars[title].exists)
    }
}
