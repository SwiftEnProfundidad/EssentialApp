//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialFeedApp
//
//  Created by Juan Carlos merlos albarracin on 17/10/24.
//

import EssentialFeed
import Foundation

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
  private let primary: FeedImageDataLoader
  private let fallback: FeedImageDataLoader

  public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
    self.primary = primary
    self.fallback = fallback
  }

  private class TaskWrapper: FeedImageDataLoaderTask {
    var wrapped: FeedImageDataLoaderTask?

    func cancel() {
      wrapped?.cancel()
    }
  }

  public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    let task = TaskWrapper()
    task.wrapped = primary.loadImageData(from: url) { [weak self] result in
      switch result {
      case .success:
        completion(result)

      case .failure:
        task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
      }

    }
    return task
  }
}
