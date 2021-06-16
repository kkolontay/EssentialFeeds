//
//  RemoteFeedLoaterTest.swift
//  EssentialFeedTests
//
//  Created by kkolontay on 6/16/21.
//

import XCTest

class RemoteFeedLoader {
  func load() {
    HTTPClient.shared.get(from: URL(string: "http://url.com")!)
  }
}
class HTTPClient {
  static var shared = HTTPClient()
  func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
  var requestedURL: URL?
  
  override func get(from url: URL) {
    requestedURL = url
  }
}

class RemoteFeedLoaterTest: XCTestCase {

  func test_init() {
    let client = HTTPClientSpy()
    _ = RemoteFeedLoader()
 
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let client = HTTPClientSpy()
    HTTPClient.shared = client
    let sut = RemoteFeedLoader()
    sut.load()
    XCTAssertNotNil(client.requestedURL)
  }

}
