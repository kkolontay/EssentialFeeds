//
//  RemoteFeedLoaterTest.swift
//  EssentialFeedTests
//
//  Created by kkolontay on 6/16/21.
//

import XCTest
@testable import EssentialFeed


class RemoteFeedLoaterTest: XCTestCase {

  func test_init() {
   
    let(_, client) = makeSUT()
 
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
  let url = URL(string: "https://a-link.com")!
    let (sut, client) = makeSUT(url: url)
    sut.load()
    XCTAssertEqual(client.requestedURL, url)
  }
  
  
  //MARK: - Helper
  private func makeSUT(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    return (sut:RemoteFeedLoader(url: url, client: client), client: client)
  }
  
  class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
      requestedURL = url
    }
  }
}
