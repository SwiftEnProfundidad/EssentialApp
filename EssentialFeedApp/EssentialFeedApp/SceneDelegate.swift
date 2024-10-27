//
//  SceneDelegate.swift
//  EssentialFeedApp
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    
    let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    let remoteClient = makeRemoteFeedClient()
    let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
    let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: remoteClient)
    
    let localStoreURL = NSPersistentContainer.defaultDirectoryURL()
      .appendingPathComponent("essential-feed")
      .appendingPathExtension("sqlite")
    
    if CommandLine.arguments.contains("-reset") {
      try? FileManager.default.removeItem(at: localStoreURL)
    }
    
    let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
    let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
    let localImageLoader = LocalFeedImageDataLoader(store: localStore)
    
    let rootViewController = FeedUIComposer.feedComposeWith(
      feedLoader: FeedLoaderWithFallbackComposite(
        primary: FeedLoaderCacheDecorator(
          decoratee: remoteFeedLoader,
          cache: localFeedLoader),
        fallback: localFeedLoader),
      imageLoader: FeedImageDataLoaderWithFallbackComposite(
        primary: remoteFeedImageDataLoader,
        fallback: FeedImageDataLoaderCacheDecorator(
          decoratee: remoteFeedImageDataLoader,
          cache: localImageLoader)))
    
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    
    self.window = window
  }
  
  private func makeRemoteFeedClient() -> HTTPClient {
    switch UserDefaults.standard.string(forKey: "connectivity") {
      case "offline":
        return AlwaysFailingHTTPClient()
      default:
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
  }
}

private class AlwaysFailingHTTPClient: HTTPClient {
  private class Task: HTTPClientTask {
    func cancel() {}
  }
  func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
    completion(.failure(NSError(domain: "offline", code: 0)))
    return Task()
  }
}
