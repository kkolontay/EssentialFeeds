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
    
    expect(sut, toCompleteWithResult: .failure(.connectivity)) {
      let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
      client.complete(with: clientError)
    }
  }
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    
    [199, 201, 300, 400, 500].enumerated().forEach { index, code in
      expect(sut, toCompleteWithResult: .failure(.invalidData)) {
        client.complete(withStatusCode: code, at: index)
      }
    }
  }
  
  func test_load_deliversNoINtemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWithResult: .success([])) {
      let emptyListJSON = Data("{\"items\": []}".utf8)
      client.complete(withStatusCode: 200, data: emptyListJSON, at: 0)
    }
  }
  
  func test_load_deliversItemsOn200HttpResponseWithJSONItems() {
    let (sut, client) = makeSUT()
    let item = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://a-url.com")!)
    let itemJSON = [
      "id": item.id.uuidString,
      "image": item.imageURL.absoluteString
    ]
    
    let item2 = FeedItem(id: UUID(), description: "location", location: "description", imageURL: URL(string: "http://a-url.com")!)
    let item2JSON = [
      "id": item2.id.uuidString,
      "image": item2.imageURL.absoluteString,
      "description": item2.description,
      "location": item2.location
    ]
    let itemsJson = [
      "items": [itemJSON, item2JSON]
    ]
    expect(sut, toCompleteWithResult: .success([item, item2])) {
      let json = try! JSONSerialization.data(withJSONObject: itemsJson, options: [])
      client.complete(withStatusCode: 200, data: json)
    }
  }
  
  func test_load_deliverysErrorOn200HTTPResponseWithINvalidJSON() {
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWithResult: .failure(.invalidData)) {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }
  
  //MARK: - Helper
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (sut: RemoteFeedLoader(url: url, client: client), client: client)
  }
  
  private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    var capturedResults = [RemoteFeedLoader.Result]()
    sut.load { capturedResults.append($0)}
    action()
    
    XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
