//
//   URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Sarika Kelkar on 21/04/22.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHTTPClientTests:XCTestCase {
//    func test_getFromURL_createDataTaskWithURL() {
//        let url = URL(string: "http://any-url.com")!
//        let session = URLSessionSpy()
//        let sut = URLSessionHTTPClient(session: session)
//        sut.get(from: url)
//        XCTAssertEqual(session.receivedURLs, [url])
//    }
    
//    func test_getFromURL_resumeDataTaskWithURL() {
//        let url = URL(string: "http://any-url.com")!
////        let session = HTTPSessionSpy()
////        let task = URLSessionDataTaskSpy()
////        session.stub(url: url, task: task)
//
//        let sut = URLSessionHTTPClient()
//        sut.get(from: url) { _ in }
//        XCTAssertEqual(task.resumeCallCount, 1)
//    }
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_getFromURL_performGetRequestWithUrl() {
        let url = anyURL()
        var receivedRequests = [URLRequest]()
        
//        exp?.expectedFulfillmentCount = 2
        URLProtocolStub.observeRequests { request in
            receivedRequests.append(request)
        }
        
        let exp = expectation(description: "wait for request completion")
        makeSUT().get(from: url) { _ in exp.fulfill()}
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedRequests.count, 1)
        XCTAssertEqual(receivedRequests.first?.url, url)
        XCTAssertEqual(receivedRequests.first?.httpMethod, "GET")
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    // test to check an invalid scenario when data = nil, urlResponse = nil, error = nil
    func test_getFromURL_failsOnAllNilValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    /*
     test to check it fails on all invalid representations like
     1. data = nil, urlResponse = URLResponse, error = nil
     2. data = nil, urlResponse = HTTPURLResponse, error = nil
     3. data = value, urlResponse = nil, error = nil
     4. data = value, urlResponse = nil, error = value
     5. data = nil, urlResponse = URLResponse, error = value
     6. data = nil, urlResponse = HTTPURLResponse, error = value
     7. data = value, urlResponse = URLResponse, error = value
     8. data = value, urlResponse = HTTPURLResponse, error = value
     9. data = value, urlResponse = URLResponse, error = nil
     */
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil)) // Its valid case
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    // test happy path data = value, urlResponse = HTTPURLResponse, error = nil
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        //Given
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        //When
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        //Then
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // test happy path data = nil, urlResponse = HTTPURLResponse, error = nil
    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        //Given
        let response = anyHTTPURLResponse()
        
        //When
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        //Then
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK:- Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error:Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error:Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error:Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response,  error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for completion")
        var receivedResult: HTTPClientResult!
        
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private class URLProtocolStub: URLProtocol {

//        var receivedURLs = [URL]()
        private static var stub : Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
//            guard let url = request.url else { return false }
//            return URLProtocolStub.stubs[url] != nil
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
//            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
//            if let requestObserver = URLProtocolStub.requestObserver {
//                client?.urlProtocolDidFinishLoading(self)
//                return requestObserver(request)
//            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
         }
        
        override func stopLoading() {
        }
    }
    
//    private class HTTPSessionSpy: HTTPSession {
//
////        var receivedURLs = [URL]()
//        private var stubs = [URL: Stub]()
//
//        private struct Stub {
//            let task: HTTPSessionTask
//            let error: Error?
//        }
//        func stub(url: URL, task: HTTPSessionTask = FakeSessionDataTask(), error: Error? = nil) {
//            stubs[url] = Stub(task: task, error: error)
//        }
//
//        func dataTask(with url: URL, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
////            self.receivedURLs.append(url)
//            guard let stub = stubs[url] else {
//                fatalError("Couldn't find stub for \(url)")
//            }
//            completionHandler(nil, nil, stub.error)
//            return stub.task
//        }
//    }
    
//    private class FakeSessionDataTask: HTTPSessionTask {
//        func resume() { }
//    }
//    private class URLSessionDataTaskSpy: HTTPSessionTask {
//        var resumeCallCount = 0
//
//        func resume() {
//            resumeCallCount += 1
//        }
//    }
}


