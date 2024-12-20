//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 30/9/24.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: () -> FeedLoader.Publisher
  private var cancellable: AnyCancellable?
  var presenter: FeedPresenter?

  init(feedLoader: @escaping () -> FeedLoader.Publisher) {
    self.feedLoader = feedLoader
  }

  func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()

    cancellable = feedLoader().sink(
      receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished: break

        case let .failure(error):
          self?.presenter?.didFinishLoadingFeed(with: error)
        }
      },
      receiveValue: { [weak self] feed in
        self?.presenter?.didFinishLoadingFeed(with: feed)
      })
  }
}
