//
//  APIManager.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import Combine
import UIKit

internal enum APIError: Error {
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

internal class APIManager {
    internal static let shared = APIManager()
    
    private init() {}
    
    internal func readLocalFile<T: Decodable>(_ type: T.Type, forName name: String) -> Future<T, APIError>  {
        Future { promise in
            do {
                guard let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                      let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) else { return promise(.failure(.dataNotFound)) }
                let data = try JSONDecoder().decode(type, from: jsonData)
                return promise(.success(data))
            } catch {
                return promise(.failure(.decodeFail))
            }
        }
    }
    
    internal func readURLJSON<T: Decodable>(_ type: T.Type, from urlString: String) -> Future<T, APIError> {
        Future { promise in
            guard let url = URL(string: urlString) else { return promise(.failure(.noURL)) }
            let session = URLSession(configuration: .default)
            let request = URLRequest(url: url)
            session.dataTask(with: request) { data, response, error in
                do {
                    if error != nil {
                        promise(.failure(.sessionError))
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       !httpResponse.isResponseOK() {
                        promise(.failure(.statusCodeError(httpResponse.statusCode)))
                    }
                    
                    guard let data else { return promise(.failure(.dataNotFound)) }
                    let decodedData = try JSONDecoder().decode(type, from: data)
                    return promise(.success(decodedData))
                } catch {
                    return promise(.failure(.decodeFail))
                }
            }.resume()
        }
    }
    
    internal func getImageURL(from urlString: String) -> Future<UIImage, APIError> {
        Future { promise in
            guard let url = URL(string: urlString) else { return promise(.failure(.noURL)) }
            let session = URLSession(configuration: .default)
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 3)
            session.dataTask(with: request) { data, response, error in
                if error != nil {
                    promise(.failure(.sessionError))
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   !httpResponse.isResponseOK() {
                    promise(.failure(.statusCodeError(httpResponse.statusCode)))
                }
                
                guard let data, let image = UIImage(data: data) else {
                    return promise(.failure(.dataNotFound))
                }
                
                return promise(.success(image))
            }.resume()
        }
    }
}

extension HTTPURLResponse {
    internal func isResponseOK() -> Bool {
        return (200...299).contains(self.statusCode)
    }
}
