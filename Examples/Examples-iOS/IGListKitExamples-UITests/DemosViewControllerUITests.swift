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
    
    func test_whenSelectingFeedView_thatFeedViewDetailScreenIsPresented() {
        enterAndAssertScreen(withTitle: "Feed View")
    }

    private func enterAndAssertScreen(withTitle title: String) {
        let app = XCUIApplication()
        app.activate()

        let cell = app.collectionViews.cells.staticTexts[title]
        scrollToElement(cell)
        XCTAssertTrue(cell.exists, "Couldn’t find demo named “\(title)”")
        cell.tap()

        let exactBar    = app.navigationBars[title]
        let compactBar  = app.navigationBars[title.replacingOccurrences(of: " ", with: "")]

        waitToAppear(element: exactBar, timeout: 2)

        if !exactBar.exists {
            waitToAppear(element: compactBar, timeout: 2)
        }

        XCTAssertTrue(
            exactBar.exists || compactBar.exists,
            "Expected a navigation bar titled “\(title)” (or its compact form) to appear"
        )
    }
}
