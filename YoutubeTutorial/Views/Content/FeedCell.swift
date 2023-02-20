//
//  FeedCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 03/02/23.
//

import Combine
import UIKit

internal class FeedCell: BaseCell {
    // MARK: UI Components
    
    private let collectionView: DiffableCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        let collection = DiffableCollectionView<DefaultSection, Video>(frame: .zero, layout: layout)
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.accessibilityIdentifier = "FeedCell.collectionView"
        return collection
    }()
    
    // MARK: Properties
    
    internal var topInset: CGFloat?
    
    internal var navigationController = CurrentValueSubject<UINavigationController?, Never>(nil)
    
    private var videos = CurrentValueSubject<[Video], Never>([Video]())
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Layouts
    
    override internal func setupViews() {
        pinSubview(collectionView)
        bindData()
        setupCollectionView()
    }
    
    // MARK: Private Implementations
    
    private func bindData() {
        NetworkManager.shared.fetchEndPointPublisher([Video].self, from: .home)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print("Home Cell Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [collectionView] videos in
                let diffableData = DiffableData<DefaultSection, Video>(section: .main, items: videos)
                collectionView.items.send([diffableData])
                
            }
            .store(in: &cancellables)
        
        navigationController
            .defaultToZero { $0?.navigationBar.frame.height }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] navigationBarHeight in
                guard let self else { return }
                self.collectionView.contentInset = UIEdgeInsets(
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

extension FeedCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(forCell: VideoCell.self)
        collectionView.setupDataSource([.main]) { collectionView, indexPath, video in
            let cell = collectionView.dequeueReusableCell(withCell: VideoCell.self, for: indexPath)
            cell.setupCell(video)
            return cell
        }
    }

    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
        let thumbnailHeight: CGFloat = (frame.width - inset - inset) * (9 / 16)
        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 80
        return CGSizeMake(frame.width, cellHeight)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let insetTop: CGFloat = topInset ?? 0.0
        let navbarHeight: CGFloat = navigationController.value?.navigationBar.frame.height ?? 0.0
        let statusBarHeight: CGFloat = insetTop - navbarHeight < 0.0 ? 0.0 : insetTop - navbarHeight
        let videoLauncher = VideoView(topInset: statusBarHeight)
        videoLauncher.showVideoPlayer()
    }
}
