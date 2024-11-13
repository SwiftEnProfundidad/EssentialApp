//
//  SceneDelegate.swift
//  EssentialFeedApp
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

import Combine
import CoreData
import EssentialFeed
import EssentialFeediOS
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()

  private lazy var store: FeedStore & FeedImageDataStore = {
    try! CoreDataFeedStore(
      storeURL:
        NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathExtension("feed-store.sqlite"))
  }()

  private lazy var localFeedLoader: LocalFeedLoader = {
    LocalFeedLoader(store: store, currentDate: Date.init)
  }()

  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
    self.init()
    self.httpClient = httpClient
    self.store = store
  }

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)

    configureWindow(whith: window)
  }

  func sceneWillResignActive(_ scene: UIScene) {
    localFeedLoader.validateCache { _ in }
  }

  func configureWindow(whith window: UIWindow) {
    let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
    let localImageLoader = LocalFeedImageDataLoader(store: store)

    let rootViewController = FeedUIComposer.feedComposedWith(
      feedLoader: makeRemoteFeedLoaderWithLocalFallback,
      imageLoader: FeedImageDataLoaderWithFallbackComposite(
        primary: localImageLoader,
        fallback: FeedImageDataLoaderCacheDecorator(
          decoratee: remoteFeedImageDataLoader,
          cache: localImageLoader)))

    window.rootViewController = UINavigationController(rootViewController: rootViewController)
    window.makeKeyAndVisible()

    self.window = window
  }

  private func makeRemoteFeedLoaderWithLocalFallback() -> RemoteFeedLoader.Publisher {
    let remoteFeedLoader = RemoteFeedLoader(url: URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!, client: httpClient)
    return
      remoteFeedLoader
      .loadPublisher()
      .caching(to: localFeedLoader)
      .fallback(to: localFeedLoader.loadPublisher)
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

private extension FeedCache {
  func saveIgnoringResult(_ feed: [FeedImage]) {
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
    InmediateWhenOnMainQueueScheduler()
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

    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
      guard Thread.isMainThread else {
        return DispatchQueue.main.schedule(options: options, action)
      }
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
