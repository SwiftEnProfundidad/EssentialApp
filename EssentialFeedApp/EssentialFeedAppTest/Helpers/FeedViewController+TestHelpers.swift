//
//  FeedViewController+TestHelpers.swift .swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import EssentialFeediOS
import UIKit

extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  @discardableResult
  func simulatedFeedImageViewVisible(at index: Int) -> FeedImageCell? {
    feedImageView(at: index) as? FeedImageCell
  }
  
  @discardableResult
  func simulatedFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
    let view = simulatedFeedImageViewVisible(at: row)
    let delegate = tableView.delegate
    let index = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    
    return view
  }
  
  func simulatedFeedImageViewNearVisible(at row: Int) {
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView(tableView, prefetchRowsAt: [index])
  }
  
  func simulatedFeedImageViewNotNearVisible(at row: Int) {
    simulatedFeedImageViewNearVisible(at: row)
    
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
  }
  
  func renderedFeedImageData(at index: Int) -> Data? {
    return simulatedFeedImageViewVisible(at: index)?.renderedImage
  }
  
  var errorMessage: String? {
    errorView?.message
  }
  
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      replacerefreshControlWithFakeForiOS17Support()
    }
    
    beginAppearanceTransition(true, animated: false) // internamente es como hacer: viewWillAppear
    endAppearanceTransition() // internamente es como hacer: viewIsAppearing+viewDidAppear
  }
  
  func replacerefreshControlWithFakeForiOS17Support() {
    let fake = FakeRefreshControl()
    
    refreshControl?.allTargets.forEach { target in
      refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
        fake.addTarget(target, action: Selector(action), for: .valueChanged)
      }
    }
    refreshControl = fake
  }
  
  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }
  
  public func numberOfRenderedFeedImageViews() -> Int {
    return tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  private var feedImagesSection: Int { 0 }
  
  func feedImagesView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
}

