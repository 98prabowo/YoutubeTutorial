//
//  PlaybackResolutionView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 17/03/23.
//

import Combine
import UIKit

internal final class PlaybackResolutionView: UIView {
    // MARK: UI Components
    
    private let collectionView: DiffableCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collection = DiffableCollectionView<DefaultSection, VideoDefinition>(frame: .zero, layout: layout)
        collection.backgroundColor = .white
        collection.allowsSelection = true
        collection.isUserInteractionEnabled = true
        collection.accessibilityIdentifier = "PlaybackResolutionView.collectionView"
        return collection
    }()
    
    private let cancelView: CancelView
    
    // MARK: Properties
    
    internal let currentReso: CurrentValueSubject<VideoDefinition, Never>
    
    internal let resoPickerDismissed = PassthroughSubject<Bool, Never>()
    
    internal var cancellables = Set<AnyCancellable>()
    
    private let iconSize: CGFloat = 25.0
    
    private let verticalInset: CGFloat = 16.0
    
    private let cencelViewHeight: CGFloat = 60.0
    
    private let resolutions: [VideoDefinition]
    
    private let areaInsets: UIEdgeInsets
    
    // MARK: Lifecycles
    
    internal init(
        areaInsets: UIEdgeInsets,
        currentReso: VideoDefinition,
        resolutions: [VideoDefinition]
    ) {
        self.areaInsets = areaInsets.add(20.0, .vertical)
        self.resolutions = resolutions
        self.currentReso = CurrentValueSubject(currentReso)
        cancelView = CancelView(areaInsets: areaInsets)
        super.init(frame: .zero)
        backgroundColor = .clear
        setupLayout()
        setupCollectionView()
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        cancelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cancelView)
        
        NSLayoutConstraint.activate([
            cancelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cancelView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cancelView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelView.heightAnchor.constraint(equalToConstant: cencelViewHeight)
        ])
        
        addSubview(collectionView)
    }
    
    private func setupFinishedLayout() {
        collectionView.removeFromSuperview()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: cancelView.topAnchor)
        ])
    }
    
    private func dismissPanel(isCancelled: Bool) {
        collectionView.removeFromSuperview()
        collectionView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(collectionView)

        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.collectionView.frame = CGRectMake(0.0, self.frame.height, self.frame.width, 0.0)
        } completion: { [weak self] _ in
            guard let self else { return }
            self.collectionView.removeFromSuperview()
            self.removeFromSuperview()
            self.resoPickerDismissed.send(isCancelled)
        }
    }
    
    // MARK: Private Implementations
    
    private func bindData() {
        currentReso
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [collectionView, resolutions] reso in
                guard let index = resolutions.firstIndex(where: { $0 == reso }) else { return }
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        cancelView.tap()
            .sink { [weak self] in
                guard let self else { return }
                self.dismissPanel(isCancelled: true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: Interfaces
    
    internal func showPanel() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
            self.collectionView.frame = CGRectMake(0.0, self.frame.height, self.frame.width, 0.0)
        } completion: { [weak self] _ in
            guard let self else { return }
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseOut
            ) { [weak self] in
                guard let self else { return }
                self.layoutIfNeeded()
                self.collectionView.frame = CGRectMake(0.0, 0.0, self.frame.width, self.frame.height - self.cencelViewHeight)
            } completion: { [weak self] _ in
                guard let self else { return }
                self.setupFinishedLayout()
            }
        }
    }
}

// MARK: - Collection View Implementation

extension PlaybackResolutionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(forCell: ResolutionCell.self)
        collectionView.setupDataSource([.main]) { [weak self] collectionView, indexPath, resolution in
            guard let self else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withCell: ResolutionCell.self, for: indexPath)
            
            cell.setupCell(
                resolution: resolution,
                iconSize: self.iconSize,
                verticalInset: self.verticalInset,
                insets: self.areaInsets
            )
            
            cell.cancellable = cell.tap()
                .sink { [weak self] in
                    guard let self else { return }
                    self.currentReso.send(resolution)
                    self.dismissPanel(isCancelled: false)
                }
            
            return cell
        }
        collectionView.items.send([DiffableData<DefaultSection, VideoDefinition>(section: .main, items: resolutions)])
    }
    
    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        let cellHeight: CGFloat = iconSize + verticalInset + verticalInset
        return CGSizeMake(frame.width, cellHeight)
    }
}
