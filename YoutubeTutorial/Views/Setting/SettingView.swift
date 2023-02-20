//
//  SettingView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal final class SettingView: UIView {
    // MARK: UI Components
    
    private let collectionView: DiffableCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collection = DiffableCollectionView<DefaultSection, Setting>(frame: .zero, layout: layout)
        collection.backgroundColor = .white
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: Properties
    
    private let settings: [Setting] = Setting.allCases
    
    internal var cancellable: AnyCancellable?
    
    internal let tapButton = PassthroughSubject<Setting, Never>()
    
    private let iconSize: CGFloat = 25.0
    
    private let verticalInset: CGFloat = 16.0
    
    private var cellHeight: CGFloat {
        iconSize + verticalInset + verticalInset
    }
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupCollectionView()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Explicitly set `UIView` height
        frame = CGRectMake(0, 0, 0, CGFloat(settings.count) * cellHeight)
    }
}

// MARK: - Collection View Implementation

extension SettingView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(forCell: SettingCell.self)
        collectionView.setupDataSource([.main]) { [iconSize, verticalInset] collectionView, indexPath, setting in
            let cell = collectionView.dequeueReusableCell(withCell: SettingCell.self, for: indexPath)
            cell.setting = setting
            cell.iconSize = iconSize
            cell.verticalInset = verticalInset
            return cell
        }
        collectionView.items.send([DiffableData<DefaultSection, Setting>(section: .main, items: settings)])
    }
    
    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        return CGSizeMake(frame.width, cellHeight)
    }
    
    internal func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let setting = collectionView.itemSource?.itemIdentifier(for: indexPath) else { return }
        tapButton.send(setting)
    }
}
