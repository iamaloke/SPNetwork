//
//  Endpoint.swift
//  RetryDemo
//
//  Created by aloksingh on 08/05/26.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    
    // Cache duration in seconds
    var cacheTime: TimeInterval { get }
}

public extension Endpoint {
    var cacheTime: TimeInterval {
        return 300 // 5 mins default
    }
}
