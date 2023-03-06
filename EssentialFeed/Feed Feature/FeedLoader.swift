//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sarika Kelkar on 20/02/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(complition: @escaping (LoadFeedResult) -> Void)
}
