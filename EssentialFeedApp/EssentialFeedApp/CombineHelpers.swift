//
//  CombineHelpers.swift
//  EssentialFeedApp
//
//  Created by Juan Carlos merlos albarracin on 14/11/24.
//

import Foundation
import Combine
import EssentialFeed

public extension FeedImageDataLoader {
  typealias Publisher = AnyPublisher<Data, Error>

  func loadImageDataPublisher(from url: URL) -> Publisher {
    var task: FeedImageDataLoaderTask?

    return Deferred {
      Future { completion in
        task = self.loadImageData(from: url, completion: completion)
      }
    }
    .handleEvents(receiveCancel: { task?.cancel() })
    .eraseToAnyPublisher()
  }
}

extension Publisher where Output == Data {
  func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveOutput: { data in
      cache.saveIgnoringResult(data, for: url)
    }).eraseToAnyPublisher()
  }
}

extension FeedImageDataCache {
  func saveIgnoringResult(_ data: Data, for url: URL) {
    save(data, for: url) { _ in }
  }
}

extension FeedLoader {
  public typealias Publisher = AnyPublisher<[FeedImage], Error>
  public func loadPublisher() -> Publisher {
    Deferred {
      Future(self.load)

    }.eraseToAnyPublisher()
  }
}

extension Publisher where Output == [FeedImage] {
  func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveOutput: cache.saveIgnoringResult)
      .eraseToAnyPublisher()
  }
}

extension FeedCache {
  fileprivate func saveIgnoringResult(_ feed: [FeedImage]) {
    save(feed) { _ in }
  }
}

extension Publisher {
  func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
    self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
  }
}

extension Publisher {
  func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
    return receive(on: DispatchQueue.inmediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
  }
}
