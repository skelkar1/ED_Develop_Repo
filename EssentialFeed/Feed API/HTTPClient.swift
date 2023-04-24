//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Sarika Kelkar on 16/04/22.
//

import Foundation

//public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
//public enum HTTPClientResult {
//    case success (Data, HTTPURLResponse)
//    case failure (Error)
//}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping(Result) -> Void)
}
