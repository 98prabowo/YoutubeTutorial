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
        collectionView.register(forCell: FeedCell.self)
        collectionView.register(forCell: TrendingCell.self)
        collectionView.register(forCell: SubscriptionsCell.self)
        collectionView.register(forCell: AccountCell.self)
    }
    
    private func showSettings() {
        let settingView = SettingView()
        let vc = ModalController(settingView)
        present(vc, animated: true)
        
        settingView.cancellable = settingView.tapButton
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
        statusBarFrame
            .receive(on: DispatchQueue.main)
            .map { [menuBarHeight] in CGRectMake($0.minX, $0.minY, $0.width, $0.height + menuBarHeight) }
            .assign(to: \.frame, on: statusBarView)
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
            .sink { [weak self] in
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
            .store(in: &menuBar.cancellable)
    }
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    override internal func collectionView(_: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return Menu.allCases.count
    }

    override internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 1:
            let cell = collectionView.dequeueReusableCell(withCell: TrendingCell.self, for: indexPath)
            cell.navigationController.send(navigationController)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withCell: SubscriptionsCell.self, for: indexPath)
            cell.navigationController.send(navigationController)
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withCell: AccountCell.self, for: indexPath)
            cell.navigationController.send(navigationController)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withCell: FeedCell.self, for: indexPath)
            cell.navigationController.send(navigationController)
            return cell
        }
    }

    internal func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        let height: CGFloat = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
        let width: CGFloat = view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        return CGSizeMake(width, height)
    }
    
    override internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.leadingConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    override internal func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        guard let menu = Menu.allCases[safe: indexPath.item] else { return }
        // Handle menu selection
        menuBar.selectItem(at: indexPath)
        
        // Handle title update
        if let titleView = navigationItem.titleView as? UILabel {
            titleView.text = menu.title
        }
    }
}
