//
//  AccountCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 06/02/23.
//

import Combine
import UIKit

internal class AccountCell: BaseCell {
    // MARK: UI Components
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: Properties
    
    private var videos = [Video]()
    
    internal var navigationController = CurrentValueSubject<UINavigationController?, Never>(nil)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Layouts
    
    override internal func setupViews() {
        pinSubview(collectionView)
        setupCollectionView()
        bindData()
    }
    
    // MARK: Private Implementations
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(forCell: VideoCell.self)
    }
    
    // MARK: Interfaces
    
    private func bindData() {
        NetworkManager.shared.fetchEndPointPublisher([Video].self, from: .home)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print("Account Cell Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] videos in
                guard let self else { return }
                self.videos = videos
                self.collectionView.reloadData()
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

extension AccountCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let video = videos[safe: indexPath.item] else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withCell: VideoCell.self, for: indexPath)
        cell.setupCell(video)
        return cell
    }

    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
        let thumbnailHeight: CGFloat = (frame.width - inset - inset) * (9 / 16)
        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 70
        return CGSizeMake(frame.width, cellHeight)
    }
}
