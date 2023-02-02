//
//  HTTPURLResponse+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Foundation

extension HTTPURLResponse {
    /// Check if the http response return good status code.
    internal func isResponseOK() -> Bool {
        return (200...299).contains(statusCode)
    }
}
