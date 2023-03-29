//
//  VideoDetailView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 28/03/23.
//

import Combine
import UIKit

internal class VideoDetailView: UIView {
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
        collection.accessibilityIdentifier = "VideoDetailView.collectionView"
        return collection
    }()
    
    // MARK: Properties
    
    internal var previousIndex: IndexPath?
    
    internal let selectedVideo = PassthroughSubject<Video, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let video: Video
    
    private let areaInsets: UIEdgeInsets
    
    // MARK: Lifecycles
    
    internal init(_ video: Video, areaInsets: UIEdgeInsets) {
        self.video = video
        self.areaInsets = areaInsets
        super.init(frame: .zero)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupViews() {
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
            } receiveValue: { [collectionView, video] videos in
                var _videos = videos
                _videos.removeAll { $0.title == video.title }
                _videos.insert(video, at: 0)
                let diffableData = DiffableData<DefaultSection, Video>(section: .main, items: _videos)
                collectionView.items.send([diffableData])
                
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - Collection View Implementations

extension VideoDetailView {
    private func setupCollectionView() {
        collectionView.register(forCell: VideoDescriptionCell.self)
        collectionView.register(forCell: VideoCellContent.self)
        collectionView.setupDataSource([.main]) { collectionView, indexPath, video in
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withCell: VideoDescriptionCell.self, for: indexPath)
                cell.setupCell(video)
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withCell: VideoCellContent.self, for: indexPath)
            cell.setupCell(video)
            cell.cancellable = cell.tap()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self else { return }
                    self.selectedVideo.send(video)
                }
            return cell
        }
    }
}
