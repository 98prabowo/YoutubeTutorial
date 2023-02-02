//
//  MenuBar.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import UIKit

internal final class MenuBar: UIView {
    // MARK: UI Components
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .redNavBar
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: Properties
    
    private let icons: [UIImage?] = .implemented
    
    // MARK: Life Cycles
    
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
        pinSubview(collectionView)
    }
    
    // MARK: Private Implementations
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(forCell: MenuCell.self)
        
        // Set initial cell selection
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
}

extension MenuBar: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let icon = icons[safe: indexPath.item] else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withCell: MenuCell.self, for: indexPath)
        cell.setupUI(icon: icon)
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(frame.width / 4, frame.height)
    }
}

extension Array where Element == UIImage? {
    internal static var implemented: [UIImage?] {
        [
            UIImage(systemName: "house.fill"),
            UIImage(systemName: "flame.fill"),
            UIImage(systemName: "play.square.stack.fill"),
            UIImage(systemName: "person.fill")
        ]
    }
}
