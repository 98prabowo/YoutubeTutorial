//
//  MainNavigationController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 03/03/23.
//

import Combine
import UIKit

internal class MainNavigationController: UINavigationController {
    // MARK: Properties
    
    override internal var prefersStatusBarHidden: Bool { statusBarHidden.value }
    
    override internal var preferredStatusBarStyle: UIStatusBarStyle { .default }
    
    private let statusBarHidden = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycles
    
    internal init() {
        let vc: UIViewController = HomeController()
        super.init(rootViewController: vc)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    // MARK: Private Implementations
    
    private func bindData() {
        NotificationCenter.default.publisher(for: .videoPlayerSizeDidChange)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.userInfo?["isMaximize"] as? Bool }
            .sink { [statusBarHidden] isMaximize in
                statusBarHidden.send(isMaximize)
            }
            .store(in: &cancellables)
        
        statusBarHidden
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .mapToVoid()
            .sink { [weak self] in
                guard let self else { return }
                self.setNeedsStatusBarAppearanceUpdate()
            }
            .store(in: &cancellables)
    }
}
