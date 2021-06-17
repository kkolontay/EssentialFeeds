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
    client.error = NSError(domain: "Test", code: 0, userInfo: nil)
    var capturedError: RemoteFeedLoader.Error?
    sut.load {
      error in
      capturedError = error
    }
    XCTAssertEqual(capturedError, .connectivity)
    
  }
  
  //MARK: - Helper
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (sut:RemoteFeedLoader(url: url, client: client), client: client)
  }
  
  class HTTPClientSpy: HTTPClient {
    
    var requestedURLs = [URL]()
    var error: Error?
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
      if let error = error {
        completion(error)
      } else {
        requestedURLs.append(url)
      }
    }
  }
}
