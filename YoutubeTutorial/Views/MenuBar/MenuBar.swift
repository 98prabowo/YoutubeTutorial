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
    
    private let horizontalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    
    private let menus: [Menu] = Menu.allCases
    
    private var leadingConstraint: NSLayoutConstraint?
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupCollectionView()
        setupHorizontalView()
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
    
    private func setupHorizontalView() {
        addSubview(horizontalView)
        leadingConstraint = horizontalView.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraint?.isActive = true
        NSLayoutConstraint.activate([
            horizontalView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalView.heightAnchor.constraint(equalToConstant: 4.0),
            horizontalView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/4)
        ])
    }
}

extension MenuBar: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let menu = menus[safe: indexPath.item] else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withCell: MenuCell.self, for: indexPath)
        cell.setupUI(menu: menu)
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(frame.width / 4, frame.height)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let x: CGFloat = CGFloat(indexPath.item) * frame.width / 4
        leadingConstraint?.constant = x
        UIView.animate(withDuration: 0.75, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
}
