//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Sarika Kelkar on 18/09/22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

