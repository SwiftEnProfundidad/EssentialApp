//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialFeedApp
//
//  Created by Juan Carlos merlos albarracin on 27/10/24.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
  func expect(_ sut: FeedImageDataLoader,
              toCompleteWith expectedResult: FeedImageDataLoader.Result,
              when action: () -> Void,
              file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    
    _ = sut.loadImageData(from: anyURL()) { receivedResult in
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
    
    action()
    
    wait(for: [exp], timeout: 1.0)
  }
}
