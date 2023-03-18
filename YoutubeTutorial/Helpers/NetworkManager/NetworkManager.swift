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
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    private var playlistCache = NSCache<NSString, NSString>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: Local load json file reader using combine
    
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
    
    internal func readLocalFilePublisher<T: Decodable>(_ type: T.Type, forName name: String) -> AnyPublisher<T, NetworkError>  {
        Just(Bundle.main.path(forResource: name, ofType: "json"))
            .tryMap { bundlePath in
                guard let bundlePath else { throw NetworkError.requestError(.jsonNotFound) }
                if let data = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                    return data
                } else {
                    throw NetworkError.dataNotFound
                }
            }
            .decode(type: type, decoder: JSONDecoder())
            .mapError { _ in NetworkError.decodeFail }
            .eraseToAnyPublisher()
    }
    
    // MARK: Network calls using combine
    
    internal func fetchURL<T: Decodable>(_ type: T.Type, from urlString: String) -> Future<T, NetworkError> {
        Future { promise in
            guard let url = URL(string: urlString) else { return promise(.failure(.requestError(.invalidURL))) }
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, response, error in
                do {
                    if let error {
                        promise(.failure(.transportError(error)))
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       !httpResponse.isResponseOK() {
                        promise(.failure(.requestError(.statusCodeError(httpResponse.statusCode))))
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
    
    internal func readURLPublisher<T: Decodable>(_ type: T.Type, from urlString: String) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: .requestError(.invalidURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { .transportError($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                if let httpResponse = response as? HTTPURLResponse,
                   !httpResponse.isResponseOK() {
                    return Fail(error: .requestError(.statusCodeError(httpResponse.statusCode)))
                        .eraseToAnyPublisher()
                } else {
                    return Just(data)
                        .decode(type: type, decoder: JSONDecoder())
                        .mapError { _ in .decodeFail }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    internal func fetchURLPublisher<T: Decodable>(_ type: T.Type, from urlString: String) -> Future<T, NetworkError> {
        Future { [weak self] promise in
            guard let self, let url = URL(string: urlString) else { return promise(.failure(.requestError(.invalidURL))) }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response in
                    if let httpResponse = response as? HTTPURLResponse,
                       !httpResponse.isResponseOK() {
                        throw NetworkError.requestError(.statusCodeError(httpResponse.statusCode))
                    }
                    return data
                }
                .decode(type: type, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        switch error {
                        case _ as DecodingError:
                            promise(.failure(.decodeFail))
                        case let networkError as NetworkError:
                            promise(.failure(networkError))
                        default:
                            promise(.failure(.transportError(error)))
                        }
                    case .finished:
                        break
                    }
                }, receiveValue: { decodedData in
                    return promise(.success(decodedData))
                })
                .store(in: &self.cancellables)
        }
    }
    
    internal func fetchEndPointPublisher<T: Decodable>(_ type: T.Type, from endpoint: EndPoint) -> Future<T, NetworkError> {
        Future { [weak self] promise in
            guard let self, let url = URL(string: endpoint.url) else { return promise(.failure(.requestError(.invalidURL))) }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response in
                    if let httpResponse = response as? HTTPURLResponse,
                       !httpResponse.isResponseOK() {
                        throw NetworkError.requestError(.statusCodeError(httpResponse.statusCode))
                    }
                    return data
                }
                .decode(type: type, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        switch error {
                        case _ as DecodingError:
                            promise(.failure(.decodeFail))
                        case let networkError as NetworkError:
                            promise(.failure(networkError))
                        default:
                            promise(.failure(.transportError(error)))
                        }
                    case .finished:
                        break
                    }
                }, receiveValue: { decodedData in
                    return promise(.success(decodedData))
                })
                .store(in: &self.cancellables)
        }
    }
    
    // MARK: Network calls to handle image with cache using combine
    
    internal func getImageURL(from urlString: String) -> Future<UIImage, NetworkError> {
        Future { promise in
            guard let url = URL(string: urlString) else { return promise(.failure(.requestError(.invalidURL))) }
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 3)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    promise(.failure(.transportError(error)))
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   !httpResponse.isResponseOK() {
                    promise(.failure(.requestError(.statusCodeError(httpResponse.statusCode))))
                }
                
                guard let data, let image = UIImage(data: data) else {
                    return promise(.failure(.dataNotFound))
                }
                
                return promise(.success(image))
            }.resume()
        }
    }
    
    internal func getImageURLPublisher(from urlString: String) -> AnyPublisher<UIImage, NetworkError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: .requestError(.invalidURL))
                .eraseToAnyPublisher()
        }
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            return Just(imageFromCache)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { NetworkError.transportError($0) }
            .flatMap { [weak self] data, response -> AnyPublisher<UIImage, NetworkError> in
                if let httpResponse = response as? HTTPURLResponse,
                   !httpResponse.isResponseOK() {
                    return Fail(error: .requestError(.statusCodeError(httpResponse.statusCode)))
                        .eraseToAnyPublisher()
                } else {
                    guard let self, let image = UIImage(data: data) else {
                        return Fail(error: .dataNotFound).eraseToAnyPublisher()
                    }
                    
                    self.imageCache.setObject(image, forKey: urlString as NSString)
                    
                    return Just(image)
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    internal func getImagePublisher(from urlString: String) -> Future<UIImage, NetworkError> {
        Future { [weak self] promise in
            guard let self, let url = URL(string: urlString) else { return promise(.failure(.requestError(.invalidURL))) }
            
            if let imageFromCache = self.imageCache.object(forKey: urlString as NSString) {
                return promise(.success(imageFromCache))
            }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response in
                    if let httpResponse = response as? HTTPURLResponse,
                       !httpResponse.isResponseOK() {
                        throw NetworkError.requestError(.statusCodeError(httpResponse.statusCode))
                    }
                    return UIImage(data: data)
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        return promise(.failure(.transportError(error)))
                    case .finished:
                        break
                    }
                }) { [weak self] image in
                    guard let self, let image else { return promise(.failure(.dataNotFound)) }
                    self.imageCache.setObject(image, forKey: urlString as NSString)
                    return promise(.success(image))
                }
                .store(in: &self.cancellables)
        }
    }
    
    // MARK: Network calls to handle video using combine
    
    internal func getResolutionPublisher(from urlString: String) -> Future<[StreamVariant], NetworkError> {
        Future { [weak self] promise in
            guard let self, let url = URL(string: urlString) else { return promise(.failure(.requestError(.invalidURL))) }
            
            if let playlistFromCache = self.playlistCache.object(forKey: urlString as NSString) {
                return promise(.success(RawPlaylist(urlPlaylist: urlString, content: playlistFromCache as String).streamResolutions))
            }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response in
                    if let httpResponse = response as? HTTPURLResponse,
                       !httpResponse.isResponseOK() {
                        throw NetworkError.requestError(.statusCodeError(httpResponse.statusCode))
                    }
                    return String(data: data, encoding: .utf8)
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        return promise(.failure(.transportError(error)))
                    case .finished:
                        break
                    }
                }) { [weak self] playlistString in
                    guard let self, let playlistString else { return promise(.failure(.dataNotFound)) }
                    let playlist = RawPlaylist(urlPlaylist: urlString, content: playlistString)
                    self.playlistCache.setObject(playlistString as NSString, forKey: urlString as NSString)
                    return promise(.success(playlist.streamResolutions))
                }
                .store(in: &self.cancellables)
        }
    }
}
