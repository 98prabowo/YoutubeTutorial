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
    
    private var videoLauncher: VideoView?
    
    // MARK: Properties
    
    internal var previousIndex: IndexPath?
    
    internal var areaInsets: UIEdgeInsets?
    
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
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case let .failure(error):
                    #if DEBUG
                        let id: String = self.accessibilityIdentifier ?? String(describing: Self.self)
                        print("\(id) network error: \(error.localizedDescription)")
                    #endif
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
        collectionView.register(forCell: VideoCellContent.self)
        collectionView.setupDataSource([.main]) { collectionView, indexPath, video in
            let cell = collectionView.dequeueReusableCell(withCell: VideoCellContent.self, for: indexPath)
            cell.setupCell(video)
            return cell
        }
    }

    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
        let thumbnailHeight: CGFloat = (frame.width - inset - inset) * (9 / 16)
        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 70.0
        return CGSizeMake(frame.width, cellHeight)
    }
    
    internal func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let video = collectionView.itemSource?.itemIdentifier(for: indexPath),
              previousIndex != indexPath
        else {
            videoLauncher?.showFullScreen()
            return
        }
        
        previousIndex = indexPath
        videoLauncher?.stopVideoPlayer()
        videoLauncher = nil
        
        let topInset: CGFloat = areaInsets?.top ?? 0.0
        let leftInset: CGFloat = areaInsets?.left ?? 0.0
        let bottomInset: CGFloat = areaInsets?.bottom ?? 0.0
        let rightInset: CGFloat = areaInsets?.right ?? 0.0
        let navbarHeight: CGFloat = navigationController.value?.navigationBar.frame.height ?? 0.0
        let statusBarHeight: CGFloat = topInset - navbarHeight < 0.0 ? 0.0 : topInset - navbarHeight
        
        videoLauncher = VideoView(
            video,
            areaInsets: UIEdgeInsets(
                top: statusBarHeight,
                left: leftInset,
                bottom: bottomInset,
                right: rightInset
            )
        )
        
        guard let videoLauncher else { return }
        videoLauncher.startVideoPlayer()
        videoLauncher.closePlayer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.videoLauncher = nil
                self.previousIndex = nil
            }
            .store(in: &videoLauncher.cancellables)
    }
}
