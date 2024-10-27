//
//  EssentialFeedAppUIAcceptanceUITests.swift
//  EssentialFeedAppUIAcceptanceUITests
//
//  Created by Juan Carlos merlos albarracin on 26/10/24.
//

import XCTest

final class EssentialFeedAppUIAcceptanceUITests: XCTestCase {
  
  func test_OnLaunch_displayRemoteNewsWhenCustomerHasConnectivity() {
    let app = XCUIApplication()
    app.launch()
    
    let feedCells = app.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(feedCells.count, 22, "There should be 22 cells")
    
    let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstImage.exists)
  }
  
  func test_onLaunch_displaysCachedRemoteNewsWhenCustomerHasNoConnectivity() {
    let onlineApp = XCUIApplication()
    onlineApp.launch()
    
    let offlineApp = XCUIApplication()
    offlineApp.launchArguments = ["-connectivity", "offline"]
    offlineApp.launch()
    
    let cacheFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(cacheFeedCells.count, 22, "There should be 22 cells")
    
    let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstCachedImage.exists)
  }
}
