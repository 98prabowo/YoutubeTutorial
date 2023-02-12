//
//  NetworkError.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Foundation

internal enum NetworkError: LocalizedError {
    internal enum RequestError {
        case invalidURL
        case jsonNotFound
        case statusCodeError(Int)
    }
    
    /// Invalid request, e.g. invalid URL
    case requestError(RequestError)
    
    /// Indicates an error on the transport layer, e.g. not being able to connect to the server
    case transportError(Error)
    
    /// Unable to find data in the memmory
    case dataNotFound
    
    /// Fail to decode received data
    case decodeFail
    
    internal var localizedDescription: String {
        switch self {
        case .requestError(.invalidURL):
            return "URL is not valid"
        case .requestError(.jsonNotFound):
            return "JSON file not found in memmory"
        case let .requestError(.statusCodeError(statusCode)):
            return "Server error: \(statusCode) error"
        case let .transportError(error):
            return "Server error: \(error.localizedDescription)"
        case .dataNotFound:
            return "Data not found or corrupt"
        case .decodeFail:
            return "Fail to decode data"
        }
    }
}
