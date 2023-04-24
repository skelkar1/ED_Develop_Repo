//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sarika Kelkar on 20/02/22.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

//public enum LoadFeedResult {
//    case success([FeedImage])
//    case failure(Error)
//}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
