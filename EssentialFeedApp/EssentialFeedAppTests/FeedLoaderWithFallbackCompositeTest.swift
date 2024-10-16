//
//  FeedLoaderWithFallbackCompositeTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 15/10/24.
//

import EssentialFeed
import XCTest

class FeedLoaderWithFallbackComposite {
  private let primary: FeedLoader
  private let fallback: FeedLoader
  
  init(primary: FeedLoader, fallback: FeedLoader) {
    self.primary = primary
    self.fallback = fallback
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    primary.load { [weak self] result in
      switch result {
        case .success:
          completion(result)
          
        case .failure:
          self?.fallback.load(completion: completion)
      }
    }
  }
}

final class FeedLoaderWithFallbackCompositeTest: XCTestCase {
  func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
    let primaryFeed = uniqueFeed()
    let fallbackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
    
    expect(sut, toCompleteWith: .success(primaryFeed))
  }
  
  func test_load_deliversFallbackNewsOnPrimaryFailure() {
    let fallbackFeed = uniqueFeed()
    let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
    
    expect(sut, toCompleteWith: .success(fallbackFeed))
  }
  
  // MARK: - Helpers
  
  private func makeSUT(primaryResult: FeedLoader.Result,
                       fallbackResult: FeedLoader.Result,
                       file: StaticString = #filePath,
                       line: UInt = #line) -> FeedLoaderWithFallbackComposite {
    let primaryLoader = LoaderStub(result: primaryResult)
    let fallbackLoader = LoaderStub(result: fallbackResult)
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
    trackMemoryLeaks(primaryLoader, file: file, line: line)
    trackMemoryLeaks(fallbackLoader, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
    }
  }
  
  private func expect(_ sut: FeedLoaderWithFallbackComposite,
                      toCompleteWith expectedResult: FeedLoader.Result,
                      file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for load to complete")
    
    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.success(receivedFeed), .success(expectedFeed)):
          XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
          
        case (.failure, .failure):
          break
          
        default:
          XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1)
  }
  
  private func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(),
               description: "any",
               location: "any",
               url: URL(string: "http://any-url.com")!)]
  }
  
  private func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
  
  private class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
      self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completion(result)
    }
  }
}
