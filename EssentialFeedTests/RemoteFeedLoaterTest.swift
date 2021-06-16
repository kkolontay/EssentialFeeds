//
//  RemoteFeedLoaterTest.swift
//  EssentialFeedTests
//
//  Created by kkolontay on 6/16/21.
//

import XCTest

class RemoteFeedLoader {
  private let client: HTTPClient
  init(client: HTTPClient) {
    self.client = client
  }
  func load() {
    client.get(from: URL(string: "http://url.com")!)
  }
}
protocol HTTPClient {
  func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
  var requestedURL: URL?
  
  func get(from url: URL) {
    requestedURL = url
  }
}

class RemoteFeedLoaterTest: XCTestCase {

  func test_init() {
    let client = HTTPClientSpy()
    _ = RemoteFeedLoader(client: client)
 
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let client = HTTPClientSpy()
    HTTPClient.shared = client
    let sut = RemoteFeedLoader(client: client)
    sut.load()
    XCTAssertNotNil(client.requestedURL)
  }

}
