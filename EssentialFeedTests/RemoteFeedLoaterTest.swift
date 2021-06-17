//
//  RemoteFeedLoaterTest.swift
//  EssentialFeedTests
//
//  Created by kkolontay on 6/16/21.
//

import XCTest
@testable import EssentialFeed


class RemoteFeedLoaterTest: XCTestCase {
  
  func test_doesnotRequestsFromURL() {
    
    let(_, client) = makeSUT()
    
    XCTAssertEqual(client.requestedURLs, [])
  }
  
  func test_load_requestDataFromURL() {
    let url = URL(string: "https://a-link.com")!
    let (sut, client) = makeSUT(url: url)
    sut.load() { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestDataFromURL() {
    let url = URL(string: "https://a-link.com")!
    let (sut, client) = makeSUT(url: url)
    sut.load() { _ in }
    sut.load() { _ in }
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    
    expect(sut, toCompleteWithError: .connectivity) {
      let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
      client.complete(with: clientError)
    }
  }
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    
    [199, 201, 300, 400, 500].enumerated().forEach { index, code in
      expect(sut, toCompleteWithError: .invalidData) {
        client.complete(withStatusCode: code, at: index)
      }
    }
  }
  
  func test_load_deliverysErrorOn200HTTPResponseWithINvalidJSON() {
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWithError: .invalidData) {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }
  
  //MARK: - Helper
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (sut: RemoteFeedLoader(url: url, client: client), client: client)
  }
  
  private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    var capturedErrors = [RemoteFeedLoader.Error]()
    sut.load { error in
      capturedErrors.append(error)
    }
    action()
    
    XCTAssertEqual(capturedErrors, [error], file: file, line: line)
  }
  
  class HTTPClientSpy: HTTPClient {
    
    private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    var requestedURLs: [URL] {
      return messages.map {
        $0.url
      }
    }
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
      messages[index].completion( .success(data, response))
      
    }
  }
}
