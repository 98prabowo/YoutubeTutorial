//
//  MenuCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import Combine
import UIKit

internal final class MenuCell: BaseCell {
    // MARK: UI Components
    
    private let tabIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .redMenuIcon
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: Properties
    
    override internal var isSelected: Bool {
        didSet {
            tabIcon.tintColor = isSelected ? .white : .redMenuIcon
        }
    }
    
    override internal var isHighlighted: Bool {
        didSet {
            tabIcon.tintColor = isHighlighted ? .white : .redMenuIcon
        }
    }
    
    internal let menu = CurrentValueSubject<Menu?, Never>(nil)
    
    private var cancellable: AnyCancellable?
    
    // MARK: Layouts
    
    override internal func setupViews() {
        addSubview(tabIcon)
        
        NSLayoutConstraint.activate([
            tabIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabIcon.widthAnchor.constraint(equalToConstant: 28),
            tabIcon.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        bindData()
    }
    
    // MARK: Implementations
    
    private func bindData() {
        cancellable = menu
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [tabIcon] menu in
                tabIcon.image = menu.icon
            }
    }
}
