//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 11/9/24.
//

import EssentialFeed
import UIKit

public protocol FeedViewControllerDelegate {
  func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
  @IBOutlet public private(set) var errorView: ErrorView?

  private var loadingController = [IndexPath: FeedImageCellController]()
  private var viewAppeared = false

  public var delegate: FeedViewControllerDelegate?

  private var tableModel = [FeedImageCellController]() {
    didSet { tableView.reloadData() }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
  }

  override public func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    if !viewAppeared {
      refresh()
      viewAppeared = true
    }
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.sizeHeaderToFit()
  }

  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }

  public func display(_ viewModel: FeedLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }

  public func display(_ cellControllers: [FeedImageCellController]) {
    loadingController = [:]
    tableModel = cellControllers
  }

  public func display(_ viewModel: FeedErrorViewModel) {
    if let message = viewModel.errorMessage {
      errorView?.show(message: message)
    } else {
      errorView?.hideMessage()
    }
  }

  override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    tableModel.count
  }

  override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cellController(forRowAt: indexPath).view(in: tableView)
  }

  override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard tableModel.count > indexPath.row else { return }
    cancelCellControllerLoad(forRowAt: indexPath)
  }

  public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      cellController(forRowAt: indexPath).preload()
    }
  }

  public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelCellControllerLoad)
  }

  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    let controller = tableModel[indexPath.row]
    loadingController[indexPath] = controller
    return controller
  }

  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancelLoad()
    loadingController[indexPath] = nil
  }
}
