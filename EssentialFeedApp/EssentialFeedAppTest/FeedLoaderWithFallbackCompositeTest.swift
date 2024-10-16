//
//  FeedLoaderWithFallbackCompositeTest.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 15/10/24.
//

import XCTest
import EssentialFeed
import EssentialFeedApp

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
  
  func test_load_deliversErrorOnBothPrimaryAndFallbackFailure() {
    let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
    
    expect(sut, toCompleteWith: .failure(anyNSError()))
  }
  
  // MARK: - Helpers
  
  private func makeSUT(primaryResult: FeedLoader.Result,
                       fallbackResult: FeedLoader.Result,
                       file: StaticString = #filePath,
                       line: UInt = #line) -> FeedLoaderWithFallbackComposite {
    let primaryLoader = FeedLoaderStub(result: primaryResult)
    let fallbackLoader = FeedLoaderStub(result: fallbackResult)
    let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
    trackForMemoryLeaks(primaryLoader, file: file, line: line)
    trackForMemoryLeaks(fallbackLoader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
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
  
}
