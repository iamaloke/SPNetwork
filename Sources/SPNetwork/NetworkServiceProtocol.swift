//
//  NetworkServiceProtocol.swift
//  RetryDemo
//
//  Created by aloksingh on 08/05/26.
//

import Foundation

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: Endpoint, responseModel: T.Type, debug: Bool) async throws -> T
}
