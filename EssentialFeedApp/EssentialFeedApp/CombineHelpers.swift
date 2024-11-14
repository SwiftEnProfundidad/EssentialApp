//
//  CombineHelpers.swift
//  EssentialFeedApp
//
//  Created by Juan Carlos merlos albarracin on 14/11/24.
//

import Combine
import EssentialFeed
import Foundation

extension FeedImageDataLoader {
  public typealias Publisher = AnyPublisher<Data, Error>

  public func loadImageDataPublisher(from url: URL) -> Publisher {
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

extension DispatchQueue {
  static var inmediateWhenOnMainQueueScheduler: InmediateWhenOnMainQueueScheduler {
    InmediateWhenOnMainQueueScheduler.shared
  }

  struct InmediateWhenOnMainQueueScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    var now: DispatchQueue.SchedulerTimeType {
      DispatchQueue.main.now
    }

    var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
      DispatchQueue.main.minimumTolerance
    }

    static let shared = Self()

    private static let key = DispatchSpecificKey<UInt8>()
    private static let value = UInt8.max

    private init() {
      DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
    }

    private func isMainQueue() -> Bool {
      return DispatchQueue.getSpecific(key: Self.key) == Self.value
    }

    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
      guard isMainQueue() else {
        return DispatchQueue.main.schedule(options: options, action)
      }

      // The main queue is guaranteed to be running on the main thread
      // The main threa is not guaranteed to be running the main queue

      action()
    }

    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
      DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
    }

    func schedule(
      after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?,
      _ action: @escaping () -> Void
    ) -> any Cancellable {
      DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
    }
  }
}
