//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sarika Kelkar on 08/03/22.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
//    public enum Result: Equatable {
//        case success([FeedItem])
//        case failure(Error)
//    }
    
    public init(url:URL, client: HTTPClient){
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url){ [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))
//                do {
//                    let items = try FeedItemsMapper.map(data, response)
//                    completion(.success(items))
//                }catch {
//                    completion(.failure(.invalidData) )
//                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map (_ data: Data, from response:HTTPURLResponse) -> Result {
        do{
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
        }
    }
}
