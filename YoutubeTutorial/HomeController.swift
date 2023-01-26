//
//  HomeController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import UIKit

class HomeController: UIViewController {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
    }
    
    override internal func loadView() {
        view = collectionView
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "home"
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .red
        collectionView.register(forCell: VideoCell.self)
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withCell: VideoCell.self, for: indexPath)
        return cell
    }

    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(view.frame.width, 200)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

internal final class VideoCell: UICollectionViewCell {
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    private let thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    internal func setupCell() {
        backgroundColor = .white
        addView(thumbnailImage, padding: UIEdgeInsets(inset: 16))
//        addView(separatorView, size: CGSize(width: 0, height: 10))
        addSubview(separatorView)
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[v0(10)]|",
                options: [],
                metrics: nil,
                views: ["v0": separatorView]
            )
        )
        
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v0]|",
                options: [],
                metrics: nil,
                views: ["v0": separatorView]
            )
        )
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
