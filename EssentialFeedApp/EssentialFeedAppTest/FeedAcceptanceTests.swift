//
//  FeedAcceptanceTests.swift
//  FeedAcceptanceTests
//
//  Created by Juan Carlos merlos albarracin on 26/10/24.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialFeedApp

final class FeedAcceptanceTests: XCTestCase {
  
  func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
    let feed = launch(httpClient: .online(response), store: .empty)
    
    feed.simulateUserInitiatedFeedReload()
    
    XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
    XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
    XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
  }
  
  func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
    let sharedStore = InMemoryFeedStore.empty
    let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
    
    onlineFeed.simulateUserInitiatedFeedReload()
    onlineFeed.simulatedFeedImageViewVisible(at: 0)
    onlineFeed.simulatedFeedImageViewVisible(at: 1)
    
    let offlineFeed = launch(httpClient: .offline, store: sharedStore)
    offlineFeed.simulateUserInitiatedFeedReload()
    
    XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
    XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
    XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
  }
  
  func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
    let feed = launch(httpClient: .offline, store: .empty)
    
    XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
  }
  
  func test_onEnteringBackground_deletesExpiredFeedCache() {
    let store = InMemoryFeedStore.withExpiredFeedCache
    
    enterBackground(with: store)
    
    XCTAssertNil(store.feedCache, "Expected to delete expired cache")
  }
  
  func test_onEnteringBackground_keepsNonExpiredFeedCache() {
    let store = InMemoryFeedStore.withNonExpiredFeedCache
    
    enterBackground(with: store)
    
    XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
  }
  
  // MARK: - Helpers
  
  private func enterBackground(with store: InMemoryFeedStore) {
    let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
    sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
  }
  
  private func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> FeedViewController {
    let sut = SceneDelegate(httpClient: httpClient, store: store)
    sut.configureWindow(whith: UIWindow())
    
    let nav = sut.window?.rootViewController as? UINavigationController
    return nav?.topViewController as! FeedViewController
  }
  
  private func response(for url: URL) -> (Data, HTTPURLResponse) {
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (makeData(for: url), response)
  }
  
  private func makeData(for url: URL) -> Data {
    switch url.absoluteString {
      case "http://image.com":
        return makeImageData()
        
      default:
        return makeFeedData()
    }
  }
  
  private func makeImageData() -> Data {
    return UIImage.make(withColor: .red).pngData()!
  }
  
  private func makeFeedData() -> Data {
    return try! JSONSerialization.data(withJSONObject: ["items": [
      ["id": UUID().uuidString, "image": "http://image.com"],
      ["id": UUID().uuidString, "image": "http://image.com"]
    ]])
  }
  
  private class HTTPClientStub: HTTPClient {
    private class Task: HTTPClientTask {
      func cancel() {}
    }
    
    private let stub: (URL) -> HTTPClient.Result
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
      self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
      completion(stub(url))
      return Task()
    }
    
    static var offline: HTTPClientStub {
      return HTTPClientStub(stub: { _ in
          .failure(NSError(domain: "offline", code: 0))
      })
    }
    
    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
      return HTTPClientStub(stub: { url in
          .success(stub(url))
      })
    }
  }
  
  private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private(set) var feedCache: CachedFeed?
    private(set) var feedImageDataCache: [URL: Data] = [:]
    
    private init(feedCache: CachedFeed? = nil) {
      self.feedCache = feedCache
    }
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
      feedCache = nil
      completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
      feedCache = CachedFeed(feed: feed, timestamp: timestamp)
      completion(.success(()))
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
      completion(.success(feedCache))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
      feedImageDataCache[url] = data
      completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
      completion(.success(feedImageDataCache[url]))
    }
    
    static var empty: InMemoryFeedStore {
      InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
      InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
      InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
    }
    
  }
}
