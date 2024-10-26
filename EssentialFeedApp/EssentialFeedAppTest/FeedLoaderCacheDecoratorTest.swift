//
//  FeedLoaderCacheDecoratorTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 17/10/24.
//

import XCTest
import EssentialFeed

protocol FeedCache {
  typealias Result = Swift.Result<Void, Error>
  
  func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
  private let decoratee: FeedLoader
  private let cache: FeedCache
  
  init(decoratee: FeedLoader, cache: FeedCache) {
    self.decoratee = decoratee
    self.cache = cache
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load { [weak self] result in
      if let feed = try? result.get() {
        self?.cache.save(feed) { _ in }
      }
      completion(result)
    }
  }
}

final class FeedLoaderCacheDecoratorTest: FeedLoaderTestCase {
  
  func test_load_deliversFeedOnLoaderSuccess() {
    let feed = uniqueFeed()
    let sut = makeSUT(loadResult: .success(feed))
    
    expect(sut, toCompleteWith: .success(feed))
  }
  
  func test_load_deliversErrorOnLoaderError() {
    let sut = makeSUT(loadResult: .failure(anyNSError()))
    
    expect(sut, toCompleteWith: .failure(anyNSError()))
  }
  
  func test_load_cachesLoadedFeedOnLoaderSuccess() {
    let cache = CacheSpy()
    let feed = uniqueFeed()
    let sut = makeSUT(loadResult: .success(feed), cache: cache)
    
    sut.load { _ in }
    
    XCTAssertEqual(cache.messages, [.save(feed)])
  }
  
  func test_load_doesNotCacheOnLoaderFailure() {
    let cache = CacheSpy()
    let sut = makeSUT(loadResult: .failure(anyNSError()), cache: cache)
    
    sut.load { _ in }
    
    XCTAssertEqual(cache.messages, [])
  }
  
  // MARK: - Helpers
  
  private func makeSUT(loadResult: FeedLoader.Result,
                       cache: CacheSpy = .init(),
                       file: StaticString = #filePath,
                       line: UInt = #line) -> FeedLoader {
    let loader = FeedLoaderStub(result: loadResult)
    let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private class CacheSpy: FeedCache {
    private(set) var messages = [Message]()
    
    enum Message: Equatable {
      case save([FeedImage])
    }
    
    func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
      messages.append(.save(feed))
      completion(.success(()))
    }
  }
}


