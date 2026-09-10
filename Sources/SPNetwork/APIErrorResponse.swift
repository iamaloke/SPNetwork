//
//  APIErrorResponse.swift
//  SPNetwork
//
//  Created by aloksingh on 10/09/26.
//

import Foundation

public struct APIErrorResponse: Decodable {
    let success: Bool
    let message: String
    let data: EmptyData?
    let timestamp: String
    let statusCode: Int
}


public struct EmptyData: Decodable {}
