//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sarika Kelkar on 23/08/22.
//

import Foundation

//public typealias RetrieveCachedFeedResult = Result<CachedFeed, Error>

//public enum RetrieveCachedFeedResult {
//    case empty
//    case found(feed: [LocalFeedImage], timestamp: Date)
//    case success(CachedFeed)
//    case failure(Error)
//}

//public enum CachedFeed {
//    case empty
//    case found(feed: [LocalFeedImage], timestamp: Date)
//}

//public struct CachedFeed {
//    public let feed: [LocalFeedImage]
//    public let timestamp: Date
//
//    public init(feed: [LocalFeedImage], timestamp: Date) {
//        self.feed = feed
//        self.timestamp = timestamp
//    }
//}

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionError = Result<Void, Error>
    typealias InsertionCompletion = (InsertionError) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrivalCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrivalCompletion)
}
