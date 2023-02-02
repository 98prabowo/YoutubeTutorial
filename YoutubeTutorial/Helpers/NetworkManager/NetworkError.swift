//
//  NetworkError.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Foundation

internal enum NetworkError: Error {
    case noURL
    case dataNotFound
    case decodeFail
    case sessionError
    case statusCodeError(Int)
    
    internal var localizedDescription: String {
        switch self {
        case .noURL:
            return "Error - URL Not valid"
        case .dataNotFound:
            return "Error - Data not found or corrupt"
        case .decodeFail:
            return "Error - Fail to decode data"
        case .sessionError:
            return "Error - URL session return error"
        case let .statusCodeError(statusCode):
            return "Server error - \(statusCode)"
        }
    }
}
