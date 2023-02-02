//
//  NetworkManager.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import Combine
import UIKit

internal class NetworkManager {
    internal static let shared = NetworkManager()
    
    private init() {}
    
    internal func readLocalFile<T: Decodable>(_ type: T.Type, forName name: String) -> Future<T, NetworkError>  {
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
    
    internal func readURLJSON<T: Decodable>(_ type: T.Type, from urlString: String) -> Future<T, NetworkError> {
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
    
    internal func getImageURL(from urlString: String) -> Future<UIImage, NetworkError> {
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
