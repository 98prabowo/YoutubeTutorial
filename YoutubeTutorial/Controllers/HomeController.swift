//
//  HomeController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import Combine
import UIKit

internal final class HomeController: UICollectionViewController {
    // MARK: UI Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRectMake(0, 0, view.frame.width - 32, view.frame.height))
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
    
    private let statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .redNavBar
        return view
    }()
    
    // MARK: Properties
    
    override internal var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private var videos: [Video] = .mock
    
    private var cancellables = Set<AnyCancellable>()
    
    private var statusBarFrame = CurrentValueSubject<CGRect, Never>(.zero)
    
    private var contentIndex: IndexPath = IndexPath(row: 0, section: 0)
    
    private let menuBarHeight: CGFloat = 50.0
    
    // MARK: Lifecycles
    
    internal init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        super.init(collectionViewLayout: layout)
        view.backgroundColor = .white
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
        guard !CGRectEqualToRect(self.statusBarFrame.value, statusBarFrame) else { return }
        self.statusBarFrame.send(statusBarFrame)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
      }
    
    // MARK: Layouts
    
    private func setupLayout() {
        view.addSubview(statusBarView)
        view.addSubview(menuBar)
        
        NSLayoutConstraint.activate([
            menuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            menuBar.heightAnchor.constraint(equalToConstant: menuBarHeight)
        ])
        
        
        // Configure collection view content inset
//        let navBarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 0.0
//        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        self.collectionView.contentInset = UIEdgeInsets(top: navBarHeight + menuBarHeight, left: 0, bottom: 0, right: 0)
//        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: navBarHeight + menuBarHeight, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: Private Implementations
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.rightBarButtonItems = [settingBtn, searchBtn]
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.register(forCell: VideoCell.self)
        collectionView.register(forCell: UICollectionViewCell.self)
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
    
    private func bindData() {
        NetworkManager.shared.readLocalFile([Video].self, forName: "home")
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
        
        statusBarFrame
            .receive(on: DispatchQueue.main)
            .sink { [statusBarView, menuBarHeight] frame in
                let statusFrame = CGRectMake(frame.minX, frame.minY, frame.width, frame.height + menuBarHeight)
                statusBarView.frame = statusFrame
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
        
        menuBar.tapMenu
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self,
                      let menu = Menu.allCases[safe: index.item] else { return }
                // Handle collection scroll
                self.collectionView.isPagingEnabled = false
                self.collectionView.scrollToItem(at: index, at: .left, animated: true)
                self.collectionView.isPagingEnabled = true
                
                // Handle title update
                self.titleLabel.text = menu.title
                let titleView = UIBarButtonItem(customView: self.titleLabel)
                self.navigationItem.setLeftBarButtonItems([titleView], animated: false)
            }
            .store(in: &menuBar.cancellables)
    }
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    override internal func collectionView(_: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return Menu.allCases.count
    }

    override internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withCell: UICollectionViewCell.self, for: indexPath)
        let colors: [UIColor] = [.green, .blue, .yellow, .orange]
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }

    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        let height: CGFloat = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
        let width: CGFloat = view.frame.width - view.safeAreaInsets.left  - view.safeAreaInsets.right
        return CGSizeMake(width, height)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.leadingConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        guard let menu = Menu.allCases[safe: indexPath.item] else { return }
        // Handle menu selection
        menuBar.selectItem(at: indexPath)
        
        // Handle title update
        self.titleLabel.text = menu.title
        let titleView = UIBarButtonItem(customView: self.titleLabel)
        self.navigationItem.setLeftBarButtonItems([titleView], animated: false)
    }
}

//extension HomeController: UICollectionViewDelegateFlowLayout {
//    override internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return videos.count
//    }
//
//    override internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let video = videos[safe: indexPath.item] else { return UICollectionViewCell() }
//        let cell = collectionView.dequeueReusableCell(withCell: VideoCell.self, for: indexPath)
//        cell.setupCell(video)
//        return cell
//    }
//
//    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let inset: CGFloat = 16
//        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
//        let thumbnailHeight: CGFloat = (view.frame.width - inset - inset) * (9 / 16)
//        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 70
//        return CGSizeMake(view.frame.width, cellHeight)
//    }
//}
