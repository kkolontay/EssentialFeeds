//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by kkolontay on 6/16/21.
//

import Foundation

enum LoadFeedResult {
  case success([FeedItem])
  case error(Error)
}

protocol FeedLoader {
  func load(completion: @escaping (LoadFeedResult) -> Void)
}
