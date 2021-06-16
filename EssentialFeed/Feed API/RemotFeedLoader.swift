//
//  RemotFeedLoader.swift
//  EssentialFeed
//
//  Created by kkolontay on 6/16/21.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL)
}

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load() {
    client.get(from: url)
  }
}

