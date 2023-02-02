//
//  HomeController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import Combine
import UIKit

internal final class HomeController: UIViewController {
    // MARK: UI Components
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
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
    
    private let searchBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.image = UIImage(systemName: "magnifyingglass")
        btn.style = .plain
        btn.tintColor = .white
        return btn
    }()
    
    private let settingBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.image = UIImage(systemName: "ellipsis.circle.fill")
        btn.style = .plain
        btn.tintColor = .white
        return btn
    }()
    
    // MARK: Properties
    
    override internal var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private var videos: [Video] = .mock
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: LifeCycles
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationBar()
        setupCollectionView()
        bindData()
        bindAction()
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
        navigationItem.rightBarButtonItems = [settingBtn, searchBtn]
    }
    
    private func showSettings() {
        let content = SettingView()
        let vc = ModalController(content)
        present(vc, animated: true)
        
        content.cancellable = content.tapButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] setting in
                guard let navController = self?.navigationController else { return }
                switch setting {
                case .cancel:
                    vc.dismissModal()
                default:
                    vc.dismissModal {
                        let settingVC = SettingController(title: setting.title)
                        navController.pushViewController(settingVC, animated: true)
                    }
                }
            }
    }
    
    private func searchAction() {
        print("Search Tapped")
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(forCell: VideoCell.self)
    }
    
    private func bindData() {
        APIManager.shared.readLocalFile([Video].self, forName: "home")
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print("Home Data: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] videos in
                guard let self else { return }
                self.videos = videos
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        searchBtn.tap()
            .sink { [weak self] _ in
                guard let self else { return }
                self.searchAction()
            }
            .store(in: &cancellables)
        
        settingBtn.tap()
            .sink { [weak self] _ in
                guard let self else { return }
                self.showSettings()
            }
            .store(in: &cancellables)
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let video = videos[safe: indexPath.item] else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withCell: VideoCell.self, for: indexPath)
        cell.setupCell(video)
        return cell
    }

    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
        let thumbnailHeight: CGFloat = (view.frame.width - inset - inset) * (9 / 16)
        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 70
        return CGSizeMake(view.frame.width, cellHeight)
    }
}
