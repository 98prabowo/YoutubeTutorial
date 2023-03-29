//
//  ContentCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 03/02/23.
//

import Combine
import UIKit

internal class ContentCell: UICollectionViewCell {
    // MARK: UI Components
    
    private let collectionView: DiffableCollectionView = {
        let layout = VideoFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collection = DiffableCollectionView<DefaultSection, Video>(frame: .zero, layout: layout)
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.accessibilityIdentifier = "ContentCell.collectionView"
        return collection
    }()
    
    private var videoLauncher: VideoView?
    
    // MARK: Properties
    
    private var previousIndex: IndexPath?
    
    private var areaInsets: UIEdgeInsets?
    
    private var navbarHeight: CGFloat?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var menu: Menu?
    
    // MARK: Layouts
    
    internal func setupViews(_ menu: Menu, areaInsets: UIEdgeInsets?, navbarHeight: CGFloat?) {
        self.menu = menu
        self.areaInsets = areaInsets
        self.navbarHeight = navbarHeight
        collectionView.contentInset = .padding(navbarHeight ?? 0.0, .top)
        
        pinSubview(collectionView)
        bindData()
        setupCollectionView()
    }
    
    // MARK: Private Implementations
    
    private func bindData() {
        menu?.service
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
    }
}

// MARK: - Collection View Implementations

extension ContentCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(forCell: VideoCellContent.self)
        collectionView.setupDataSource([.main]) { collectionView, indexPath, video in
            let cell = collectionView.dequeueReusableCell(withCell: VideoCellContent.self, for: indexPath)
            cell.setupCell(video)
            return cell
        }
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
        
        let navbarHeight: CGFloat = navbarHeight ?? 0.0
        let videoInsets: UIEdgeInsets = areaInsets
            .zeroIfNil
            .substract(navbarHeight, .top, lowest: 0.0)
        
        videoLauncher = VideoView(video, areaInsets: videoInsets)
        
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
