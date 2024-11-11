//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

public struct FeedErrorViewModel {
    public let errorMessage: String?

    public static var noError: FeedErrorViewModel {
        FeedErrorViewModel(errorMessage: nil)
    }

    public static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(errorMessage: message)
    }
}
