//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 17/10/24.
//

import XCTest

extension XCTestCase {
  func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }
}

