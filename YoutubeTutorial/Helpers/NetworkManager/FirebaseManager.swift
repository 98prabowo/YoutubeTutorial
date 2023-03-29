//
//  FirebaseManager.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 29/03/23.
//

import Combine
import Firebase

internal struct FirebaseManager {
    internal static let shared = FirebaseManager()
    
    private let referenceDB = Database.database().reference()
    
    private init() {}
    
    internal func fetchAllData(_ menu: Menu) -> Future<[Video], NetworkError> {
        Future { promise in
            referenceDB
                .child(menu.rawValue)
                .child("videos")
                .observeSingleEvent(of: .value, with: { snapshot in
                    guard let videoRawArray = snapshot.value as? [AnyObject] else {
                        promise(.failure(.requestError(.jsonNotFound)))
                        return
                    }
                    var videos = [Video]()
                    videoRawArray.forEach {
                        guard let videoDict = $0 as? [String: Any],
                              let video = Video(videoDict) else {
                            promise(.failure(.decodeFail))
                            return
                        }
                        videos.append(video)
                    }
                    promise(.success(videos))
                })
        }
    }
}
