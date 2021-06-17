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
    sut.load()
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestDataFromURL() {
    let url = URL(string: "https://a-link.com")!
    let (sut, client) = makeSUT(url: url)
    sut.load()
    sut.load()
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    
    var capturedErrors = [RemoteFeedLoader.Error]()
    sut.load {
      capturedErrors.append($0)
    }
    let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
    client.complete(with: clientError)
    XCTAssertEqual(capturedErrors, [.connectivity])
    
  }
  
  //MARK: - Helper
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (sut:RemoteFeedLoader(url: url, client: client), client: client)
  }
  
  class HTTPClientSpy: HTTPClient {
    
    var requestedURLs = [URL]()
    var completions = [(Error) -> Void]()
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
      
      completions.append(completion)
        requestedURLs.append(url)
    }
    
    func complete(with error: Error, at index: Int = 0) {
      completions[index](error)
    }
  }
}
