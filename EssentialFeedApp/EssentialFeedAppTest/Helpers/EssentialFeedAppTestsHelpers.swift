//
//  EssentialFeedAppTestsHelpers.swift
//  EssentialFeedAppTests
//
//  Created by Juan Carlos merlos albarracin on 17/10/24.
//

import Foundation

func anyNSError() -> NSError {
  NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  URL(string: "http://any-url.com")!
}

func anyData() -> Data {
  Data("any data".utf8)
}
