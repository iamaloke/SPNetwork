// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class NetworkManager: NetworkServiceProtocol {
    
    private let config: APIConfig
    private let session: URLSession
    private let maxRetryCount = 3
    
    public init(config: APIConfig) {
        self.config = config
        let configuration = URLSessionConfiguration.default
        
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024,
            diskPath: "network_cache"
        )
        
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: configuration)
    }
    
}

// MARK: - Retry Logic

extension NetworkManager {
    
    func makeURL(path: String) throws -> URL {
        guard let url = config.baseURL else { throw APIError.invalidURL }
        return url.appendingPathComponent(path)
    }
    
    public func request<T: Decodable & Sendable>(endpoint: Endpoint, responseModel: T.Type, debug: Bool = false) async throws -> T {
        let url = try makeURL(path: endpoint.path)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.httpBody = endpoint.body
        
        endpoint.headers?.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }
        
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        if debug {
            debugPrint("""
            🚀 REQUEST
            
            URL:
            \(urlRequest.url?.absoluteString ?? "")
            
            Method:
            \(urlRequest.httpMethod ?? "")
            
            Headers:
            \(urlRequest.allHTTPHeaderFields ?? [:])
            
            Body:
            \(String(data: urlRequest.httpBody ?? Data(), encoding:.utf8 ) ?? "request body empty")
            
            """)
        }
        
        return try await performRequest(request: urlRequest, retryCount: maxRetryCount, responseModel: responseModel, debug: debug)
    }
    
    public func performRequest<T: Decodable & Sendable>(request: URLRequest, retryCount: Int, responseModel: T.Type, debug: Bool = false) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if debug {
                debugPrint("""
            ✅ RESPONSE
            
            Status:
            \(httpResponse.statusCode)
            
            Body:
            \(String(data: data, encoding: .utf8) ?? "")
            """)
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                let errorResponse = try? JSONDecoder() .decode(APIErrorResponse.self, from: data)
                throw APIError.serverError(errorResponse?.error ?? "Something went wrong", httpResponse.statusCode )
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch {
            let shouldRetry: Bool
            
            switch error {
            case APIError.serverError(_, let code):
                shouldRetry = (500...599).contains(code)
                
            case APIError.network:
                shouldRetry = true
                
            default:
                shouldRetry = false
            }
            
            if shouldRetry && retryCount > 0 {
                if debug {
                    debugPrint("Retrying... attempts left: \(retryCount - 1)")
                }
                return try await performRequest(request: request, retryCount: retryCount - 1, responseModel: responseModel, debug: debug)
            }
            
            throw error
        }
    }
}
