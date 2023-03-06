//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Sarika Kelkar on 16/04/22.
//

import Foundation


internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
    }
    
    private static var OK_200: Int { return 200 }
//    internal static func map (_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem]{
//        guard response.statusCode == OK_200 else {
//            throw RemoteFeedLoader.Error.invalidData
//        }
//        let root = try JSONDecoder().decode(Root.self, from: data)
//        return root.items.map{ $0.item }
//
//    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
//        do {
//            let root = try JSONDecoder().decode(Root.self, from: data)
//            let items = root.items.map{ $0.item }
        return root.items
//        }catch {
//            return (.failure(.invalidData) )
//        }
    }
}
