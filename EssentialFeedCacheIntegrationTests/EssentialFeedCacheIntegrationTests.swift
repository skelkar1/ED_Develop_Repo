//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by sarika kelkar on 08/04/23.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
        
//        let exp = expectation(description: "wait for load completiom")
//        sut.load { result in
//            switch result {
//            case let .success(imageFeed):
//                XCTAssertEqual(imageFeed, [], "Expected empty feed")
//            case let .failure(error):
//                XCTFail("Expected successful feed result, got \(error) instead")
//            }
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutToPerformSave)
//        let saveExp = expectation(description: "Wait to save completion")
//        sutToPerformSave.save(feed) { saveError in
//            XCTAssertNil(saveError, "Expected to save feed successfully")
//            saveExp.fulfill()
//        }
//        wait(for: [saveExp], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: feed)
//        let loadExp = expectation(description: "Wait for load completion")
//        sutToPerformLoad.load { loadResult in
//            switch loadResult {
//            case let .success(imageFeed):
//                XCTAssertEqual(imageFeed, feed)
//
//            case let .failure(error):
//                XCTFail("Expected successful feed result, got \(error) instead")
//            }
//            loadExp.fulfill()
//        }
//        wait(for: [loadExp], timeout: 1.0)
    }
    
    func test_save_overridesItemsSavedOnSeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
//        let saveExp1 = expectation(description: "Wait for save completion")
//        sutToPerformFirstSave.save(firstFeed) { saveError in
//            XCTAssertNil(saveError, "Expected to save feed successfully")
//            saveExp1.fulfill()
//        }
//        wait(for: [saveExp1], timeout: 1.0)
        
        save(latestFeed, with: sutToPerformLastSave)
//        let saveExp2 = expectation(description: "Wait for save completion")
//        sutToPerformLastSave.save(latestFeed) { saveError in
//            XCTAssertNil(saveError, "Expected to save feed successfully")
//            saveExp2.fulfill()
//        }
//        wait(for: [saveExp2], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
        
    }
    
    //- MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
//        let store = CodableFeedStore(storeURL: storeURL)
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file:file, line:line)
        trackForMemoryLeaks(sut, file:file, line:line)
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
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line){
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
            
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
}
