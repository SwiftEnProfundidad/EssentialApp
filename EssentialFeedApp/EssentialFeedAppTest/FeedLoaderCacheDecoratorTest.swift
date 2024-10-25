//
//  FeedLoaderCacheDecoratorTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 17/10/24.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
  private let decoratee: FeedLoader
  
  init(decoratee: FeedLoader) {
    self.decoratee = decoratee
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load(completion: completion)
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
  
  // MARK: - Helpers
  
  private func makeSUT(loadResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoader {
    let loader = FeedLoaderStub(result: loadResult)
    let sut = FeedLoaderCacheDecorator(decoratee: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}


