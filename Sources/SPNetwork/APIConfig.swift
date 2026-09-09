//
//  APIConfig.swift
//  SPNetwork
//
//  Created by aloksingh on 09/09/26.
//

import Foundation

public struct APIConfig {
    public let baseURL: URL
    public let apiKey: String?
    
    public init(baseURL: URL, apiKey: String? = nil) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
}
