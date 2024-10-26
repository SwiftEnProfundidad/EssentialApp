//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 26/10/24.
//

import Foundation

public protocol FeedCache {
  typealias Result = Swift.Result<Void, Error>
  
  func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
