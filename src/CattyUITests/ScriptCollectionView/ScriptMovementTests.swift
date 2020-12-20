/**
 *  Copyright (C) 2010-2021 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

class ScriptMovementTests: XCTestCase {

    var app: XCUIApplication!
    let projectName = "testProject"

    override func setUp() {
        super.setUp()
        let defaultLaunchArguments = ["UITests", "skipPrivacyPolicy", "restoreDefaultProject", "disableAnimations"]
        app = launchApp(with: defaultLaunchArguments)

        createProject(name: projectName, in: app)
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        addBrick(label: kLocalizedHide, section: kLocalizedCategoryLook, in: app)
        addBrick(label: kLocalizedSetX, section: kLocalizedCategoryMotion, in: app)
        app.staticTexts[kLocalizedSetX].tap()
        addBrick(label: kLocalizedSetY, section: kLocalizedCategoryMotion, in: app)
        app.staticTexts[kLocalizedSetY].tap()

        addBrick(label: kLocalizedWhenTapped, section: kLocalizedCategoryEvent, in: app)
        app.staticTexts[kLocalizedWhenTapped].tap()
        addBrick(label: kLocalizedShow, section: kLocalizedCategoryLook, in: app)
        let showBrick = app.collectionViews.cells.element(boundBy: 4)
        showBrick.press(forDuration: 0.5, thenDragTo: app.collectionViews.cells.element(boundBy: 5))
        //app.staticTexts[kLocalizedShow].tap()

        addBrick(label: kLocalizedBecomesTrue, section: kLocalizedCategoryEvent, in: app)
        app.staticTexts[kLocalizedBecomesTrue].tap()
        addBrick(label: kLocalizedMove, section: kLocalizedCategoryMotion, in: app)
        let moveBrick = app.collectionViews.cells.element(boundBy: 6)
        moveBrick.press(forDuration: 0.5, thenDragTo: app.collectionViews.cells.element(boundBy: 7))

        let firstBrick = app.collectionViews.cells.element(boundBy: 1)
        let secondBrick = app.collectionViews.cells.element(boundBy: 2)
        let thirdBrick = app.collectionViews.cells.element(boundBy: 3)

        let firstScript = app.collectionViews.cells.element(boundBy: 0)
        let secondScript = app.collectionViews.cells.element(boundBy: 4)
        let thirdScript = app.collectionViews.cells.element(boundBy: 6)

        XCTAssertEqual(app.collectionViews.cells.count, 8)

        XCTAssertTrue(firstScript.staticTextEquals(kLocalizedWhenProjectStarted, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(firstBrick.staticTextEquals(kLocalizedHide, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(secondBrick.staticTextEquals(kLocalizedSetX, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(thirdBrick.staticTextEquals(kLocalizedSetY, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(secondScript.staticTextEquals(kLocalizedWhenTapped, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(thirdScript.staticTextEquals(kLocalizedBecomesTrue, ignoreLeadingWhiteSpace: true).exists)
    }

    func testMoveScriptUp() {
        let thirdScript = app.collectionViews.children(matching: .cell).element(boundBy: 6)
        thirdScript.tap()

        let moveBrickButton = app.sheets[kLocalizedEditScript].scrollViews.otherElements.buttons[kLocalizedMoveScript]
        moveBrickButton.tap()

        thirdScript.press(forDuration: 0.5, thenDragTo: app.collectionViews.cells.element(boundBy: 0))

        app.navigationBars[kLocalizedScripts].buttons[kLocalizedBackground].tap()
        app.navigationBars[kLocalizedBackground].buttons[projectName].tap()
        app.navigationBars[projectName].buttons[kLocalizedPocketCode].tap()

        waitForElementToAppear(app.staticTexts[projectName]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        let firstScript = app.collectionViews.cells.element(boundBy: 0)
        let firstBrick = app.collectionViews.cells.element(boundBy: 1)
        let secondBrick = app.collectionViews.cells.element(boundBy: 2)
        let lastScript = app.collectionViews.cells.element(boundBy: 6)

        XCTAssertTrue(app.staticTexts[kLocalizedWhenProjectStarted].waitForExistence(timeout: 2))

        XCTAssertTrue(firstScript.staticTextEquals(kLocalizedBecomesTrue, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(firstBrick.staticTextEquals(kLocalizedMove, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(secondBrick.staticTextEquals(kLocalizedWhenProjectStarted, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(lastScript.staticTextEquals(kLocalizedWhenTapped, ignoreLeadingWhiteSpace: true).exists)
    }

    func testBrickMoveScriptDown() {
        let scriptToDrag = app.collectionViews.children(matching: .cell).element(boundBy: 4)
        scriptToDrag.tap()

        let moveBrickButton = app.sheets[kLocalizedEditScript].scrollViews.otherElements.buttons[kLocalizedMoveScript]
        moveBrickButton.tap()

        scriptToDrag.press(forDuration: 0.5, thenDragTo: app.collectionViews.cells.element(boundBy: 8))

        app.navigationBars[kLocalizedScripts].buttons[kLocalizedBackground].tap()
        app.navigationBars[kLocalizedBackground].buttons[projectName].tap()
        app.navigationBars[projectName].buttons[kLocalizedPocketCode].tap()

        waitForElementToAppear(app.staticTexts[projectName]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        let firstScript = app.collectionViews.cells.element(boundBy: 0)
        let secondScript = app.collectionViews.cells.element(boundBy: 4)
        let brickOfSecondScript = app.collectionViews.cells.element(boundBy: 5)
        let thirdScript = app.collectionViews.cells.element(boundBy: 6)
        let lastBrick = app.collectionViews.cells.element(boundBy: 7)

        XCTAssertTrue(app.staticTexts[kLocalizedWhenProjectStarted].waitForExistence(timeout: 2))

        XCTAssertTrue(firstScript.staticTextEquals(kLocalizedWhenProjectStarted, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(secondScript.staticTextEquals(kLocalizedBecomesTrue, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(brickOfSecondScript.staticTextEquals(kLocalizedMove, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(thirdScript.staticTextEquals(kLocalizedWhenTapped, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(lastBrick.staticTextEquals(kLocalizedShow, ignoreLeadingWhiteSpace: true).exists)
    }
}
