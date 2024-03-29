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
        let collection = DiffableCollectionView<DefaultSection, Menu>(frame: .zero, layout: layout)
        collection.backgroundColor = .redNavBar
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.accessibilityIdentifier = "MenuBar.collectionView"
        return collection
    }()
    
    private let horizontalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "MenuBar.horizontalView"
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
    
#if DEBUG
    deinit {
        print(">>> \(String(describing: Self.self)) deinitialize safely 👍🏽")
    }
#endif
    
    // MARK: Layouts
    
    private func setupLayout() {
        pinSubview(collectionView)
    }
    
    // MARK: Private Implementations
    
    private func setupHorizontalView() {
        addSubview(horizontalView)
        leadingConstraint = horizontalView.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraint?.isActive = true
        
        let horizontalWidthMultiplier: CGFloat = 1.0 / CGFloat(menus.count)
        NSLayoutConstraint.activate([
            horizontalView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalView.heightAnchor.constraint(equalToConstant: 4.0),
            horizontalView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: horizontalWidthMultiplier)
        ])
    }
}

// MARK: - Collection View Implementation

extension MenuBar: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(forCell: MenuCell.self)
        collectionView.setupDataSource([.main]) { collectionView, indexPath, menu in
            let cell = collectionView.dequeueReusableCell(withCell: MenuCell.self, for: indexPath)
            cell.menu.send(menu)
            return cell
        }
        
        collectionView.items.send([DiffableData<DefaultSection, Menu>(section: .main, items: menus)])
        
        // Set initial cell selection.
        // Need to dispatch to main to make it serial with collection view update snapshot task.
        DispatchQueue.main.async {
            self.selectItem(at: self.tapMenu.value)
        }
    }
    
    internal func selectItem(at indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        return CGSizeMake(frame.width / CGFloat(menus.count), frame.height)
    }
    
    internal func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapMenu.send(indexPath)
    }
}
