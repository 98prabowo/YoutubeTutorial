//
//  HomeController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import UIKit

internal final class HomeController: UIViewController {
    // MARK: UI Components
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRectMake(0, 0, view.frame.width - 32, view.frame.height))
        label.text = "Home"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let menuBar: MenuBar = {
        let menu = MenuBar()
        menu.translatesAutoresizingMaskIntoConstraints = false
        return menu
    }()
    
    // MARK: Properties
    
    override internal var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: LifeCycles
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationBar()
        setupCollectionView()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        view.addSubview(menuBar)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            menuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            menuBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: menuBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: Private Implementations
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(forCell: VideoCell.self)
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withCell: VideoCell.self, for: indexPath)
        cell.setupUI()
        return cell
    }

    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        let thumbnailHeight: CGFloat = (view.frame.width - inset - inset) * (9 / 16) // Video pixel aspect ratio w: 16 h: 9
        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 70
        return CGSizeMake(view.frame.width, cellHeight)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
