//
//  EndPoint.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 13/02/23.
//

import Foundation

internal enum EndPoint {
    case home
    case trending
    case subscriptions
    case account
    
    private var baseURL: String { "https://s3-us-west-2.amazonaws.com/youtubeassets" }
    
    private var fileType: String { "json" }
    
    internal var url: String {
        switch self {
        case .home:
            return baseURL + "/home." + fileType
        case .trending:
            return baseURL + "/trending." + fileType
        case .subscriptions:
            return baseURL + "/subscriptions." + fileType
        case .account:
            return baseURL + "/account." + fileType
        }
    }
}
