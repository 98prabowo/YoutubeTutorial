//
//  DiffableCollectionController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 13/02/23.
//

import Combine
import UIKit

internal enum DefaultSection { case main }

internal class DiffableCollectionController<ItemIdentifierType>: UICollectionViewController where ItemIdentifierType : Hashable, ItemIdentifierType : Sendable {
    // MARK: - Value Types
    
    internal typealias DataSource = UICollectionViewDiffableDataSource<DefaultSection, ItemIdentifierType>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<DefaultSection, ItemIdentifierType>
    
    // MARK: Properties
    
    internal var items = CurrentValueSubject<[ItemIdentifierType], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    
    private var dataSource: DataSource?
    
    // MARK: Lifecycles
    
    internal init(layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    // MARK: Implementations
    
    internal func setupDataSource(cellProvider: @escaping DataSource.CellProvider) {
        let source = DataSource(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
        dataSource = source
        setupSnapshot(items.value, animating: false)
    }
    
    private func setupSnapshot(_ items: [ItemIdentifierType], animating: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot, animatingDifferences: animating)
    }
    
    private func bindData() {
        items
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self else { return }
                self.setupSnapshot(data, animating: true)
            }
            .store(in: &cancellables)
    }
    
    internal func append(_ item: ItemIdentifierType) {
        var currentItems = items.value
        currentItems.append(item)
        items.send(currentItems)
    }
    
    internal func remove(_ item: ItemIdentifierType) {
        var currentItems = items.value
        if let index = currentItems.firstIndex(of: item) {
            currentItems.remove(at: index)
            items.send(currentItems)
        }
    }
}

internal class DiffableCollectionView<ItemIdentifierType>: UICollectionView where ItemIdentifierType : Hashable, ItemIdentifierType : Sendable {
    // MARK: - Value Types
    
    internal typealias ItemSource = UICollectionViewDiffableDataSource<DefaultSection, ItemIdentifierType>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<DefaultSection, ItemIdentifierType>
    
    // MARK: Properties
    
    internal var items = CurrentValueSubject<[ItemIdentifierType], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    
    private var itemSource: ItemSource?
    
    internal init(frame: CGRect, layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        bindData()
    }

    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Implementations
    
    private func setupSnapshot(_ items: [ItemIdentifierType], animating: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        itemSource?.apply(snapshot, animatingDifferences: animating)
    }
    
    private func bindData() {
        items
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self else { return }
                self.setupSnapshot(data, animating: true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: Interfaces
    
    internal func setupDataSource(cellProvider: @escaping ItemSource.CellProvider) {
        let source = ItemSource(
            collectionView: self,
            cellProvider: cellProvider
        )
        itemSource = source
        setupSnapshot(items.value, animating: false)
    }
    
    internal func append(_ item: ItemIdentifierType) {
        var currentItems = items.value
        currentItems.append(item)
        items.send(currentItems)
    }
    
    internal func remove(_ item: ItemIdentifierType) {
        var currentItems = items.value
        if let index = currentItems.firstIndex(of: item) {
            currentItems.remove(at: index)
            items.send(currentItems)
        }
    }
}
