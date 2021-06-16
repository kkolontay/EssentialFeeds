//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by kkolontay on 6/16/21.
//

import Foundation

protocol FeedLoader {
  func load(completion: @escaping () -> Void)
}
