//
//  TrendingCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 06/02/23.
//

import Combine
import UIKit

internal class TrendingCell: BaseCell {
    // MARK: UI Components
    
    private let collectionView: DiffableCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        let collection = DiffableCollectionView<Video>(frame: .zero, layout: layout)
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: Properties
    
    private var videos = CurrentValueSubject<[Video], Never>([Video]())
    
    internal var navigationController = CurrentValueSubject<UINavigationController?, Never>(nil)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Layouts
    
    override internal func setupViews() {
        pinSubview(collectionView)
        setupCollectionView()
        bindData()
    }
    
    // MARK: Private Implementations
    
    private func bindData() {
        NetworkManager.shared.fetchEndPointPublisher([Video].self, from: .trending)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print("Home Cell Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [collectionView] videos in
                collectionView.items.send(videos)
            }
            .store(in: &cancellables)
        
        navigationController
            .defaultToZero { $0?.navigationBar.frame.height }
            .receive(on: DispatchQueue.main)
            .sink { [collectionView] navigationBarHeight in
                collectionView.contentInset = UIEdgeInsets(
                    top: navigationBarHeight,
                    left: 0.0,
                    bottom: 0.0,
                    right: 0.0
                )
                collectionView.scrollIndicatorInsets = UIEdgeInsets(
                    top: navigationBarHeight,
                    left: 0.0,
                    bottom: 0.0,
                    right: 0.0
                )
            }
            .store(in: &cancellables)
    }
}

// MARK: - Collection View Implementation

extension TrendingCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(forCell: VideoCell.self)
        collectionView.setupDataSource { collectionView, indexPath, video in
            let cell = collectionView.dequeueReusableCell(withCell: VideoCell.self, for: indexPath)
            cell.setupCell(video)
            return cell
        }
    }

    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
        let thumbnailHeight: CGFloat = (frame.width - inset - inset) * (9 / 16)
        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 70
        return CGSizeMake(frame.width, cellHeight)
    }
}
