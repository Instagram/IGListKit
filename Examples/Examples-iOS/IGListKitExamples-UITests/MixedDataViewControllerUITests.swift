/*
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import XCTest

final class MixedDataViewControllerUITests: UITestCase {

    override func setUp() {
        super.setUp()
        enterMixedDataDetailScreen()
    }

    func test_whenSelectingAll_thatAllSectionTypesArePresent() {
        mixedDataNavigationBarElement().buttons["All"].tap()

        XCTAssertTrue(expandableSectionElement().exists)
        XCTAssertTrue(userSectionElement().exists)
        XCTAssertTrue(gridSectionElement().exists)
    }

    func test_whenSelectingColors_thatOnlyGridSectionsArePresent() {
        mixedDataNavigationBarElement().buttons["Colors"].tap()

        XCTAssertFalse(expandableSectionElement().exists)
        XCTAssertFalse(userSectionElement().exists)
        XCTAssertTrue(gridSectionElement().exists)
    }

    func test_whenSelectingText_thatOnlyExpandableSectionsArePresent() {
        mixedDataNavigationBarElement().buttons["Text"].tap()

        XCTAssertTrue(expandableSectionElement().exists)
        XCTAssertFalse(userSectionElement().exists)
        XCTAssertFalse(gridSectionElement().exists)
    }

    func test_whenSelectingUsers_thatOnlyUserSectionsArePresent() {
        mixedDataNavigationBarElement().buttons["Users"].tap()

        XCTAssertFalse(expandableSectionElement().exists)
        XCTAssertTrue(userSectionElement().exists)
        XCTAssertFalse(gridSectionElement().exists)
    }

    func test_whenExpandingExpandableSection_thatHeightIsIncreased() {
        mixedDataNavigationBarElement().buttons["Text"].tap()

        let expandableSection = expandableSectionElement()
        let collapsedFrame = expandableSection.frame

        // Expand
        expandableSection.tap()
        let expandedFrame = expandableSection.frame

        XCTAssertTrue(expandedFrame.size.height > collapsedFrame.size.height)
    }

    func test_whenCollapsingExpandableSection_thatHeightIsDecreased() {
        mixedDataNavigationBarElement().buttons["Text"].tap()

        let expandableSection = expandableSectionElement()

        // Expand
        expandableSection.tap()
        let expandedFrame = expandableSection.frame

        // Collapse
        expandableSection.tap()
        let collapsedFrame = expandableSection.frame

        XCTAssertTrue(collapsedFrame.size.height < expandedFrame.size.height)
    }

    private func expandableSectionElement() -> XCUIElement {
        return XCUIApplication().collectionViews.cells.staticTexts.element(matching: NSPredicate(format: "label == %@", "Maecenas faucibus mollis interdum. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit."))
    }

    private func userSectionElement() -> XCUIElement {
        return XCUIApplication().collectionViews.cells.staticTexts["@ryanolsonk"]
    }

    private func gridSectionElement() -> XCUIElement {
        return XCUIApplication().collectionViews.cells.staticTexts["1"]
    }

    private func mixedDataNavigationBarElement() -> XCUIElement {
        return XCUIApplication().navigationBars["Mixed Data"]
    }

    private func enterMixedDataDetailScreen() {
        XCUIApplication().collectionViews.cells.staticTexts["Mixed Data"].tap()
    }

}
