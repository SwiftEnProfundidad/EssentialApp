//
//  SceneDelegateTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 28/10/24.
//

import EssentialFeediOS
import XCTest

@testable import EssentialFeedApp

final class SceneDelegateTest: XCTestCase {

  func test_sceneWillConnectToSession_configurationRootViewController() {
    let sut = SceneDelegate()
    sut.configureWindow(whith: UIWindow())

    let root = sut.window?.rootViewController
    let rootNavigation = root as? UINavigationController
    let topViewController = rootNavigation?.topViewController

    XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
    XCTAssertTrue(
      topViewController is FeedViewController, "Expected a feed view controller as top view controller, got \(String(describing: topViewController)) instead")
  }

  func test_configureWindow_setWindowAsKeyAndVisible() {
    let window = UIWindow()
    window.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene

    let sut = SceneDelegate()
    sut.window = window

    sut.configureWindow(whith: window)

    XCTAssertTrue(window.isKeyWindow, "Expected window to be the key window")
    XCTAssertFalse(window.isHidden, "Expected window to be visible")
  }

}
