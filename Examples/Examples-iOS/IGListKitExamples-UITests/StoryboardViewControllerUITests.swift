//
//  StoryboardViewControllerUITests.swift
//  IGListKitExamples
//
//  Created by Huylens on 2017/7/1.
//  Copyright © 2017年 Instagram. All rights reserved.
//

import XCTest

final class StoryboardUITests: UITestCase {
    var lastPointY:CGFloat = -1;
    func test_whenScrollToTheBottom(){
        let collectionViews = XCUIApplication().collectionViews
        collectionViews.cells.staticTexts["Storyboard"].tap()
        
        var count = collectionViews.cells.count
        
        while scrollable(){
            collectionViews.element.swipeUp()
            
        }
        while (count > 1){
            count = collectionViews.cells.count
            
            if verdictContentSize(){
                let cell = collectionViews.cells.element(boundBy: count - 1)
                //tap to remove last cell
                cell.tap()
                collectionViews.element.swipeUp()
            }
        }
        XCTAssertTrue(true)
        
        
    }
    private func scrollable()-> Bool{
        let collectionViews = XCUIApplication().collectionViews
        let pointY = collectionViews.cells.element(boundBy: 0).frame.origin.y
        if pointY == lastPointY{
            
            return false
        }else{
            lastPointY = pointY
            return true
        }
    }
    
    private func verdictContentSize()-> Bool{
        let collectionViews = XCUIApplication().collectionViews
        let count = collectionViews.cells.count
        for i in 0..<count{
            let cellFrame = collectionViews.cells.element(boundBy: count - i - 1).frame
            if collectionViews.element.frame.contains(cellFrame){
            }else{
                //collectionview's frame does not contains the cell's frame
                XCTAssertTrue(false, "collectionview's frame does not contains the cell's(at index:\(count - i - 1)) frame")
                return false
            }
            
            if cellFrame.origin.x == 0{
                //the last whole line has been traversed
                break;
            }
        }
        return true
    }
}
