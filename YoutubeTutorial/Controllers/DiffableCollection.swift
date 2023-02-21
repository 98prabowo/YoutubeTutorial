//
//  DiffableCollectionController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 13/02/23.
//

import Combine
import UIKit

internal enum DefaultSection { case main }

internal struct DiffableData<SectionIdentifierType,ItemIdentifierType>: Hashable where SectionIdentifierType : Hashable, SectionIdentifierType : Sendable, ItemIdentifierType : Hashable, ItemIdentifierType : Sendable {
    internal var section: SectionIdentifierType
    internal var items: [ItemIdentifierType]
}

internal class DiffableCollectionController<SectionIdentifierType,ItemIdentifierType>: UICollectionViewController where SectionIdentifierType : Hashable, SectionIdentifierType : Sendable, ItemIdentifierType : Hashable, ItemIdentifierType : Sendable {
    // MARK: - Value Types
    
    internal typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    // MARK: Properties
    
    internal var data = CurrentValueSubject<[DiffableData<SectionIdentifierType, ItemIdentifierType>], Never>([])
    
    private var cancellable: AnyCancellable?
    
    private var snapshot = Snapshot()
    
    private var dataSource: DataSource?
    
    // MARK: Lifecycles
    
#if DEBUG
    deinit {
        print(">>> \(String(describing: Self.self)) deinitialize safely 👍🏽")
    }
#endif

    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    // MARK: Implementations
    
    private func setupSnapshot(_ data: [DiffableData<SectionIdentifierType, ItemIdentifierType>], animating: Bool) {
        if !self.data.value.isEmpty {
            snapshot.deleteAllItems()
        }
        snapshot.appendSections(data.map(\.section))
        snapshot.appendItems(data.flatMap(\.items))
        dataSource?.apply(snapshot, animatingDifferences: animating)
    }
    
    private func bindData() {
        cancellable = data
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self else { return }
                self.setupSnapshot(data, animating: true)
            }
    }
    
    // MARK: Interfaces
    
    internal func setupDataSource(_ defaultSection: [SectionIdentifierType], cellProvider: @escaping DataSource.CellProvider) {
        let source = DataSource(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
        dataSource = source
        let defaultData: [DiffableData<SectionIdentifierType, ItemIdentifierType>] = defaultSection.map {
            DiffableData(section: $0, items: [])
        }
        setupSnapshot(defaultData, animating: false)
    }
    
    internal func remove(_ sections: [SectionIdentifierType]) {
        snapshot.deleteSections(sections)
    }
    
    internal func remove(_ items: [ItemIdentifierType]) {
        snapshot.deleteItems(items)
    }
}

internal class DiffableCollectionView<SectionIdentifierType,ItemIdentifierType>: UICollectionView where SectionIdentifierType : Hashable, SectionIdentifierType : Sendable, ItemIdentifierType : Hashable, ItemIdentifierType : Sendable {
    // MARK: - Value Types
    
    internal typealias ItemSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    // MARK: Properties
    
    internal var items = CurrentValueSubject<[DiffableData<SectionIdentifierType, ItemIdentifierType>], Never>([])
    
    private var cancellable: AnyCancellable?
    
    private var snapshot = Snapshot()
    
    internal var itemSource: ItemSource?
    
    internal init(frame: CGRect, layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        bindData()
    }

    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Implementations
    
    private func setupSnapshot(_ items: [DiffableData<SectionIdentifierType, ItemIdentifierType>], animating: Bool) {
        if !self.items.value.isEmpty {
            snapshot.deleteAllItems()
        }
        snapshot.appendSections(items.map(\.section))
        snapshot.appendItems(items.flatMap(\.items))
        itemSource?.apply(snapshot, animatingDifferences: animating)
    }
    
    private func bindData() {
        cancellable = items
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self else { return }
                self.setupSnapshot(data, animating: true)
            }
    }
    
    // MARK: Interfaces
    
    internal func setupDataSource(_ defaultSection: [SectionIdentifierType], cellProvider: @escaping ItemSource.CellProvider) {
        let source = ItemSource(
            collectionView: self,
            cellProvider: cellProvider
        )
        itemSource = source
        let defaultData: [DiffableData<SectionIdentifierType, ItemIdentifierType>] = defaultSection.map {
            DiffableData(section: $0, items: [])
        }
        setupSnapshot(defaultData, animating: false)
    }
    
    internal func remove(_ sections: [SectionIdentifierType]) {
        snapshot.deleteSections(sections)
    }
    
    internal func remove(_ items: [ItemIdentifierType]) {
        snapshot.deleteItems(items)
    }
}
