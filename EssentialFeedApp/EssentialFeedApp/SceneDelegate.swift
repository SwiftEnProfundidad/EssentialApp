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
    let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
    let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: remoteClient)
    
    let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("essential-feed").appendingPathExtension("sqlite")
    let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
    let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
    let localImageLoader = LocalFeedImageDataLoader(store: localStore)
    
    let rootViewController = FeedUIComposer.feedComposeWith(
      feedLoader: FeedLoaderWithFallbackComposite(
        primary: remoteFeedLoader,
        fallback: localFeedLoader),
      imageLoader: FeedImageDataLoaderWithFallbackComposite(
        primary: remoteFeedImageDataLoader,
        fallback: localImageLoader))
    
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    
    self.window = window
  }
}
