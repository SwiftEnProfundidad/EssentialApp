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
  
  let localStoreURL = NSPersistentContainer.defaultDirectoryURL()
    .appendingPathComponent("essential-feed")
    .appendingPathExtension("sqlite")
  
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    
    configureWindow(whith: window)
  }
  
  func configureWindow(whith window: UIWindow)  {
    let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    let remoteClient = makeRemoteClient()
    let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
    let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: remoteClient)
    
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
    
    window.rootViewController = UINavigationController(rootViewController: rootViewController)
    window.makeKeyAndVisible()
    
    self.window = window
  }
  
  func makeRemoteClient() -> HTTPClient {
    return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }
}
