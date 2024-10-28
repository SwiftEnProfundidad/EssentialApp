//
//  SceneDelegateTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 28/10/24.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeedApp

final class SceneDelegateTest: XCTestCase {

  func test_sceneWillConnectToSession_configurationRootViewController() {
    let sut = SceneDelegate()
    sut.configureWindow(whith: UIWindow())
    
    let root = sut.window?.rootViewController
    let rootNavigation = root as? UINavigationController
    let topViewController = rootNavigation?.topViewController
    
    XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
    XCTAssertTrue(topViewController is FeedViewController, "Expected a feed view controller as top view controller, got \(String(describing: topViewController)) instead")
  }
}
