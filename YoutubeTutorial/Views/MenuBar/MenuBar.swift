//
//  MenuBar.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import Combine
import UIKit

internal final class MenuBar: UIView {
    // MARK: UI Components
    
    private let collectionView: DiffableCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        let collection = DiffableCollectionView<Menu>(frame: .zero, layout: layout)
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
    
    internal var leadingConstraint: NSLayoutConstraint?
    
    internal var cancellable = Set<AnyCancellable>()
    
    internal let tapMenu = CurrentValueSubject<IndexPath, Never>(IndexPath(item: 0, section: 0))
    
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

// MARK: - Collection View Implementation

extension MenuBar: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(forCell: MenuCell.self)
        collectionView.setupDataSource { collectionView, indexPath, menu in
            let cell = collectionView.dequeueReusableCell(withCell: MenuCell.self, for: indexPath)
            cell.menu.send(menu)
            return cell
        }
        
        collectionView.items.send(menus)
        
        // Set initial cell selection. Need to dispatch to main to make it serial with collection view.
        DispatchQueue.main.async {
            self.selectItem(at: self.tapMenu.value)
        }
    }
    
    internal func selectItem(at indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        return CGSizeMake(frame.width / 4, frame.height)
    }
    
    internal func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapMenu.send(indexPath)
    }
}
