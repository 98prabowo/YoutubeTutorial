//
//  SettingController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import UIKit

internal final class SettingController: UIViewController {
    // MARK: Lifecycles
    
    internal init(title: String) {
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = title
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
#if DEBUG
    deinit {
        print(">>> \(String(describing: Self.self)) deinitialize safely 👍🏽")
    }
#endif
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
    }
}
