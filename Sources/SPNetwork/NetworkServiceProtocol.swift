//
//  NetworkServiceProtocol.swift
//  RetryDemo
//
//  Created by aloksingh on 08/05/26.
//

import Foundation

public protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable & Sendable>(endpoint: Endpoint, responseModel: T.Type, debug: Bool) async throws -> T
}
