//
//  RemoteFeedLoaterTest.swift
//  EssentialFeedTests
//
//  Created by kkolontay on 6/16/21.
//

import XCTest

class RemoteFeedLoader {
  func load() {
    HTTPClient.shared.requestedURL = URL(string: "http://url.com")
  }
}
class HTTPClient {
  static let shared = HTTPClient()
  private init() {}
  var requestedURL: URL?
}

class RemoteFeedLoaterTest: XCTestCase {

  func test_init() {
    let client = HTTPClient.shared
    _ = RemoteFeedLoader()
 
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let client = HTTPClient.shared
    let sut = RemoteFeedLoader()
    sut.load()
    XCTAssertNotNil(client.requestedURL)
  }

}
