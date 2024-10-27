//
//  EssentialFeedAppUIAcceptanceUITests.swift
//  EssentialFeedAppUIAcceptanceUITests
//
//  Created by Juan Carlos merlos albarracin on 26/10/24.
//

import XCTest

final class EssentialFeedAppUIAcceptanceUITests: XCTestCase {
  
  func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
    let app = XCUIApplication()
    app.launchArguments = ["--reset", "-connectivity", "online"]
    app.launch()
    
    let feedCells = app.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(feedCells.count, 2, "There should be 2 cells")
    
    let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstImage.exists)
  }
  
  func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
    let onlineApp = XCUIApplication()
    onlineApp.launchArguments = ["--reset", "-connectivity", "online"]
    onlineApp.launch()
    
    let offlineApp = XCUIApplication()
    offlineApp.launchArguments = ["-connectivity", "offline"]
    offlineApp.launch()
    
    let cacheFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(cacheFeedCells.count, 2, "There should be 2 cells")
    
    let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstCachedImage.exists)
  }
  
  func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
    let app = XCUIApplication()
    app.launchArguments = ["--reset", "-connectivity", "offline"]
    app.launch()
    
    let feedCells = app.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(feedCells.count, 0, "There should be 0 cells")
    
    let firstEmptyImage = app.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertFalse(firstEmptyImage.exists)
  }
}
