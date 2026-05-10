// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class NetworkManager: NetworkServiceProtocol {
    
    private let session: URLSession
    private let maxRetryCount = 3
    
    public init() {
        
        let configuration = URLSessionConfiguration.default
        
        // URLCache Configuration
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024,
            diskPath: "network_cache"
        )
        
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: configuration)
    }
    
    public func request<T: Decodable & Sendable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T {
        
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.httpBody = endpoint.body
        
        endpoint.headers?.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }
        
        // Cache policy
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        return try await performRequest(request: urlRequest, retryCount: maxRetryCount, responseModel: responseModel)
    }
}

// MARK: - Retry Logic

extension NetworkManager {
    
    public func performRequest<T: Decodable>(request: URLRequest, retryCount: Int, responseModel: T.Type) async throws -> T {
        do {
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                // Retry only for server errors
                if retryCount > 0, 500...599 ~= httpResponse.statusCode {
                    print("Retrying... attempts left: \(retryCount)")
                    return try await performRequest(request: request, retryCount: retryCount - 1, responseModel: responseModel)
                }
                
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch {
            // Retry for network failures
            if retryCount > 0 {
                print("Retrying due to network error...")
                return try await performRequest(request: request, retryCount: retryCount - 1, responseModel: responseModel)
            }
            
            throw APIError.network(error)
        }
    }
}
