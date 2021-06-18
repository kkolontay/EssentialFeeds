//
//  RemotFeedLoader.swift
//  EssentialFeed
//
//  Created by kkolontay on 6/16/21.
//

import Foundation


public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public enum Result: Equatable {
    case success([FeedItem])
    case failure(Error)
  }
  
  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard let self = self else {
        return completion(.failure(.connectivity))
      }
      switch result {
      case .success(let data, let response):
        completion(self.map( data, from: response))
      case .failure:
        completion(.failure(.connectivity))
      }
    }
  }
  private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    if let items = try? FeedItemsMapper.map(data, response) {
    return .success(items)
    } else {
      return .failure(.invalidData)
    }
  }
}

