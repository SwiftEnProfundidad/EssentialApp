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
  
  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()
  
  private lazy var store: FeedStore & FeedImageDataStore = {
    try! CoreDataFeedStore(storeURL: NSPersistentContainer
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
  
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    
    configureWindow(whith: window)
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    localFeedLoader.validateCache { _ in }
  }
  
  func configureWindow(whith window: UIWindow)  {
    let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
    let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
    let localImageLoader = LocalFeedImageDataLoader(store: store)
    
    let imageLoader = FeedImageDataLoaderWithFallbackComposite(
      primary: localImageLoader,
      fallback: FeedImageDataLoaderCacheDecorator(
        decoratee: remoteFeedImageDataLoader,
        cache: localImageLoader
      )
    )
    
    let rootViewController = FeedUIComposer.feedComposedWith(
      feedLoader: FeedLoaderWithFallbackComposite(
        primary: FeedLoaderCacheDecorator(
          decoratee: remoteFeedLoader,
          cache: localFeedLoader),
        fallback: localFeedLoader),
      imageLoader: imageLoader)
    
    window.rootViewController = UINavigationController(rootViewController: rootViewController)
    window.makeKeyAndVisible()
    
    self.window = window
  }
}
