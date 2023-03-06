//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by sarika kelkar on 12/11/22.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStore{
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    //MARK: - Retrieve use cases
    //Use case: Empty cache returns empty
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    //Use case: Empty cache twice has no side effects, returns empty
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    //Use case: Non-empty cache returns data
    //Use case: To empty cache stores data
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    //Use case: Non-empty cache twice returns same data (no side-effects)
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assetThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
   
    //Use case: Error returns error(if applicable, e.g., invalid data)
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to:storeURL, atomically: false, encoding: .utf8)
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    //Use case: Error twice returns same error(if applicable, e.g., invalid data)
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to:storeURL, atomically: false, encoding: .utf8)
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    //Use case: To non-empty cache overriders previous data with new data
    func test_insert_deliversNoErrorOnEmptyCache(){
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliverNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        _ = insert((latestFeed, latestTimestamp), to: sut)
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on:sut)
    }
    
    //Use case: Error returns error(if applicable, e.g., no write permission)
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        assetThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    //Use case: Empty cache does nothing (cache stays empty and does not fail)
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    //Use case: Non-empty cache leaves cache empty
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    //Use case: Error (if applicable, e.g., no delete permission)
    func test_delete_deliversErrorOnDeletionError() {
        let nonDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletePermissionURL)
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let nonDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletePermissionURL)
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    //MARK: - Helper
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line:UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
       return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    //MARK: - Retrieve use cases
    //Use case: Empty cache returns empty
    //Use case: Empty cache twice has no side effects, returns empty
    //Use case: Non-empty cache returns data
    //Use case: Non-empty cache twice returns same data (no side-effects)
    //Use case: Error returns error(if applicable, e.g., invalid data)
    //Use case: Error twice returns same error(if applicable, e.g., invalid data)
    
    //MARK: - Insert use cases
    //Use case: To empty cache stores data
    //Use case: To non-empty cache overriders previous data with new data
    //Use case: Error returns error(if applicable, e.g., no write permission)
    
    //MARK: - Delete use cases
    //Use case: Empty cache does nothing (cache stays empty and does not fail)
    //Use case: Non-empty cache leaves cache empty
    //Use case: Error (if applicable, e.g., no delete permission)
    
    //Side-effects must run serially to avoid race-condition

}
