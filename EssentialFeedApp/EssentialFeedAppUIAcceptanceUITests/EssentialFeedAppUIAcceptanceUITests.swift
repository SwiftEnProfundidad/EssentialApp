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
    
    XCTAssertEqual(app.cells.count, 22, "There should be 22 cells")
    XCTAssertEqual(app.cells.images.count, 22, "There should be 22 images")
  }
}
