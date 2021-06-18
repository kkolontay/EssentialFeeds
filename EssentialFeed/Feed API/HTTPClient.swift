//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by kkolontay on 6/18/21.
//

import Foundation

public enum HTTPClientResult {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}



public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
