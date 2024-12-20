//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 18/9/24.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import UIKit

public final class FeedUIComposer {
  private init() {}

  public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: @escaping (URL) ->  FeedImageDataLoader.Publisher) -> FeedViewController {
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
    let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)

    presentationAdapter.presenter = FeedPresenter(
      feedView: FeedViewAdapter(
        controller: feedController,
        imageLoader: { imageLoader($0).dispatchOnMainQueue() }),
      loadingView: WeakRefVirtualProxy(feedController), errorView: WeakRefVirtualProxy(feedController)
    )
    return feedController
  }

  private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = delegate
    feedController.title = title
    return feedController
  }
}
