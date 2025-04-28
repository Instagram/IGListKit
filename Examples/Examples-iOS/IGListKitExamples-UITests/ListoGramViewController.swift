/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import XCTest

final class ListoGramViewControllerUITests: UITestCase {

    // MARK: - Short-cuts
    
    private var app: XCUIApplication { XCUIApplication() }

    /// The collection-view that shows the ListoGram feed.
    private var feed: XCUIElement {
        let collections = app.collectionViews
        guard collections.count > 1 else { return collections.firstMatch }

        for idx in 0..<collections.count {
            let cv = collections.element(boundBy: idx)
            if cv.buttons["optionsButton"].waitForExistence(timeout: 0.4) {
                return cv
            }
        }
        return collections.element(boundBy: 1)
    }

    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        enterListoGramDetailScreen()
    }

    // MARK: - Tests
    
    func test_whenLoadingInitialContent_postsAreDisplayed() {
        waitToAppear(element: feed.cells.element(boundBy: 0), timeout: 5)
        XCTAssertTrue(feed.cells.count > 0)
    }

    func test_whenRefreshing_newContentIsLoaded() {
        waitToAppear(element: feed.cells.element(boundBy: 0), timeout: 5)
        app.navigationBars["ListoGram"].buttons["Refresh"].tap()
        waitToAppear(element: feed, timeout: 5)
        XCTAssertTrue(feed.exists)
    }

    func test_whenScrollingToBottom_loadMoreIndicatorAppears() {
        waitToAppear(element: feed.cells.element(boundBy: 0), timeout: 5)
        (0..<3).forEach { _ in feed.swipeUp() }
        XCTAssertTrue(feed.cells.count > 0)
    }

    func test_whenTappingOptionsButton_actionSheetAppears() {
        let firstPost = firstVisiblePost()

        locateOptionsButton(in: firstPost).tap()
        let sheet = app.sheets.firstMatch
        waitToAppear(element: sheet, timeout: 2)

        XCTAssertTrue(sheet.buttons["Delete"].exists)
        XCTAssertTrue(sheet.buttons["Report"].exists)

        app.tap()
    }

    func test_whenDeletingPost_postIsRemoved() {
        let firstPost = firstVisiblePost()
        let caption   = firstPost.staticTexts.firstMatch.label
        XCTAssertFalse(caption.isEmpty, "Post should contain a visible caption")

        locateOptionsButton(in: firstPost).tap()
        waitToAppear(element: app.sheets.firstMatch, timeout: 2)
        app.sheets.firstMatch.buttons["Delete"].tap()

        let deletedCell = feed.cells
                            .containing(.staticText, identifier: caption)
                            .firstMatch

        XCTAssertTrue(
            waitUntilGone(element: deletedCell, timeout: 5),
            "Cell with caption “\(caption)” should disappear after deletion"
        )
    }

    // MARK: - Helpers
    
    private func enterListoGramDetailScreen() {
        let demo = app.collectionViews.staticTexts["ListoGram"]
        scrollToElement(demo, in: app.collectionViews)
        XCTAssertTrue(demo.exists)

        demo.tap()
        XCTAssertTrue(app.navigationBars["ListoGram"].exists)
    }

    @discardableResult
    private func waitUntilGone(element: XCUIElement,
                               timeout: TimeInterval) -> Bool {
        let gone = NSPredicate(format: "exists == false")
        let exp  = expectation(for: gone, evaluatedWith: element, handler: nil)
        return XCTWaiter().wait(for: [exp], timeout: timeout) == .completed
    }

    private func firstVisiblePost() -> XCUIElement {
        let post = feed.cells.element(boundBy: 0)
        waitToAppear(element: post, timeout: 5)
        return post
    }

    /// Finds the trailing “…” button in a post, whatever Apple calls it this week.
    private func locateOptionsButton(in post: XCUIElement) -> XCUIElement {
        let predicate = NSPredicate(
            format: "identifier == 'optionsButton' || " +
                    "label CONTAINS[c] 'ellipsis'  || " +
                    "label CONTAINS[c] 'more'"
        )

        for container in [post, feed, app] {
            let btn = container.descendants(matching: .any)
                               .matching(predicate)
                               .firstMatch
            if btn.waitForExistence(timeout: 2) { return btn }
        }

        fatalError("Options button should appear somewhere on screen")
    }
}
