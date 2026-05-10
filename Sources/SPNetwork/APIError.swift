//
//  APIError.swift
//  RetryDemo
//
//  Created by aloksingh on 08/05/26.
//

import Foundation

public enum APIError: Error {
    
    // MARK: - Request Errors
    case invalidURL
    case invalidRequest
    
    // MARK: - Network Errors
    case network(Error)
    case noInternet
    case timeout
    
    // MARK: - Response Errors
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(_ code: Int)
    
    // MARK: - Parsing Errors
    case decodingError(Error)
    case encodingError(Error)
    
    // MARK: - Custom Errors
    case custom(message: String)
    case unknown
}

extension APIError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
            
        case .invalidURL:
            return "The URL is invalid."
            
        case .invalidRequest:
            return "The request could not be created."
            
        case .network(let error):
            return error.localizedDescription
            
        case .noInternet:
            return "No internet connection. Please check your network."
            
        case .timeout:
            return "The request timed out. Please try again."
            
        case .invalidResponse:
            return "Invalid response received from the server."
            
        case .unauthorized:
            return "You are not authorized. Please login again."
            
        case .forbidden:
            return "You do not have permission to access this resource."
            
        case .notFound:
            return "Requested resource was not found."
            
        case .serverError(let statusCode):
            return "Server error occurred. Status code: \(statusCode)"
            
        case .decodingError:
            return "Failed to decode server response."
            
        case .encodingError:
            return "Failed to encode request body."
            
        case .custom(let message):
            return message
            
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
