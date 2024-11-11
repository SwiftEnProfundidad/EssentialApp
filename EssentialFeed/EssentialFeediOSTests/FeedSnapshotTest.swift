//
//  FeedSnapshotTest.swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 4/11/24.
//

import XCTest
import EssentialFeed
@testable import EssentialFeediOS

final class FeedSnapshotTest: XCTestCase {
  
  func test_emtpyList() {
    let sut = makeSUT()
    
    sut.display(emptyFeed())
    record(snapshot: sut.snapshot(), name: "EMPTY_FEED")
  }
  
  func test_feedWithContent() {
    let sut = makeSUT()
    
    sut.display(feedWithContent())
    record(snapshot: sut.snapshot(), name: "FEED_WITH_CONTENT")
  }
  
  func test_feedWithErrorMessage() {
    let sut = makeSUT()
    
    sut.display(.error(message: "This is a\nmulti-line\nerror a message"))
    record(snapshot: sut.snapshot(), name: "FEED_WITH_ERROR_MESSAGE")
  }
  
  func test_feedWithFailedImageLoading() {
    let sut = makeSUT()
    
    sut.display(feedWithFailedImageLoading())
    record(snapshot: sut.snapshot(), name: "FEED_WITH_FAILED_IMAGE_LOADING")
  }
  
  // MARK: - Helpers
  
  private func makeSUT() -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! FeedViewController
    controller.loadViewIfNeeded()
    return controller
  }
  
  private func emptyFeed() -> [FeedImageCellController] {
    return []
  }
  
  private func feedWithContent() -> [ImageStub] {
    return [
      ImageStub(
        description: "The East Side Gallery is an open-air gallery in San Francisco, California. It consists of a series of murals painted directly on a 1,250-opening-pixel wide strip, viewed from a distance of 240 feet, that is located on Exchange Street in the East Side between 7th and 8th arrondissements of the city.",
        location: "East Side Gallery\nSan Francisco",
        image: UIImage.make(withColor: .red)
      ),
      ImageStub(
        description: "Garth Pier is a Grade II listed structure in San Francisco. The structure, which was named after the garage that leads to the Pier, was built in 1906.",
        location: "Garth Pier\nSan Francisco",
        image: UIImage.make(withColor: .green)
      )
    ]
  }
  
  private func feedWithFailedImageLoading() -> [ImageStub] {
    return [
      ImageStub(description: nil, location: "Cannon Street, London", image: nil),
      ImageStub(description: nil, location: "Brighton Tower, London", image: nil)
    ]
  }
  
  private func record(snapshot: UIImage, name: String, file: StaticString = #file, line: UInt = #line) {
    guard let snapshotData = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
      return
    }
    
    // ../EssentialFeediOSTests/snapshot/EMPTY_FEED.png
    let snapshotURL = URL(fileURLWithPath: String(describing: file))
      .deletingLastPathComponent()
      .appendingPathComponent("snapshots")
      .appendingPathComponent("\(name).png")
    
    do {
      try FileManager.default.createDirectory(
        at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try snapshotData.write(to: snapshotURL)
    } catch {
      XCTFail("Failed to record snapshot vith error: \(error)", file: file, line: line)
    }
  }
}

private class ImageStub: FeedImageCellControllerDelegate {
  let viewModel: FeedImageViewModel<UIImage>
  weak var controller: FeedImageCellController?
  
  init(description: String?, location: String?, image: UIImage?) {
    viewModel = FeedImageViewModel(
      description: description,
      location: location,
      image: image,
      isLoading: false,
      shouldRetry: image == nil)
  }
  
  func didRequestImage() {
    controller?.display(viewModel)
  }
  
  func didCancelImageRequest() { }
}

extension UIViewController {
  func snapshot() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
    return renderer.image { action in
      view.layer.render(in: action.cgContext)
    }
  }
}

private extension FeedViewController {
  func display(_ stubs: [ImageStub]) {
    let cells: [FeedImageCellController] = stubs.map { stub in
      let cellController = FeedImageCellController(delegate: stub)
      stub.controller = cellController
      return cellController
    }
    display(cells)
  }
}
