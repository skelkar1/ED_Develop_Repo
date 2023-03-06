//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Sarika Kelkar on 24/08/22.
//

import Foundation

internal struct RemoteFeedItem : Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
