//
//  ModalController.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal final class ModalController: UIViewController {
    // MARK: Enums
    
    internal enum Size {
        case fitContent
        case halfScreen
    }
    
    internal enum Style {
        case flat
        case curveSlider
        case curveCloseButton
    }
    
    // MARK: UI Components
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let dragView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton()
        btn.tintColor = .label
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let contentView: UIView
    
    // MARK: Properties
    
    private let size: Size
    
    private let style: Style
    
    private let maxTopSpace: CGFloat = 90.0
    
    private var containerHeight: CGFloat {
        let height: CGFloat
        
        switch size {
        case .fitContent:
            let containerHeight: CGFloat = contentView.frame.height + 20.0
            let calculatedY: CGFloat = view.frame.height - containerHeight
            height = calculatedY >= maxTopSpace ? containerHeight : view.frame.height - maxTopSpace
        case .halfScreen:
            height = view.frame.height / 2.0
        }
        
        return height + view.safeAreaInsets.bottom
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycles
    
    internal init(_ view: UIView, size: Size = .fitContent, style: Style = .flat) {
        contentView = view
        self.size = size
        self.style = style
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupGesture()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentContent()
    }
    
    // MARK: Implementations
    
    internal func dismissModal(completion: (() -> Void)? = nil) {
        dismissContent(completionHandler: completion)
    }
    
    // MARK: Private Methods
    
    private func presentContent() {
        backgroundView.frame = view.frame
        setupContainer()
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        let calculatedY: CGFloat = view.frame.height - containerHeight
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut) {
            self.backgroundView.alpha = 1.0
            self.containerView.frame = CGRectMake(0.0, calculatedY, self.view.frame.width, self.containerHeight)
        }
    }
    
    private func dismissContent(completionHandler: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5) {
            self.backgroundView.alpha = 0.0
            self.containerView.frame = CGRectMake(0.0, self.view.frame.height, self.containerView.frame.width, self.containerView.frame.height)
        } completion: { _ in
            self.backgroundView.removeFromSuperview()
            self.contentView.removeFromSuperview()
            self.containerView.removeFromSuperview()
            self.dismiss(animated: false, completion: completionHandler)
        }
    }
    
    private func setupGesture() {
        backgroundView.tap()
            .sink { [weak self] _ in
                guard let self else { return }
                self.dismissContent()
            }
            .store(in: &cancellables)
    }
    
    private func setupButton() {
        closeButton.action()
            .sink { [weak self] _ in
                guard let self else { return }
                self.dismissContent()
            }
            .store(in: &cancellables)
    }
    
    private func setupContainer() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = true
        containerView.frame = CGRectMake(0.0, view.frame.height, view.frame.width, containerHeight)
        
        switch style {
        case .flat:
            containerView.addSubview(contentView)
            
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: view.safeAreaInsets.bottom)
            ])
            
        case .curveSlider:
            let cornerRadius: CGFloat = 30.0
            let dragHeight: CGFloat = 4.0
            let dragTopPadding: CGFloat = 10.0
            dragView.layer.cornerRadius = dragHeight / 2.0
            
            containerView.roundSpecificCorners([.topLeft, .topRight], radius: cornerRadius)
            containerView.addSubview(dragView)
            containerView.addSubview(contentView)
            
            NSLayoutConstraint.activate([
                dragView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: dragTopPadding),
                dragView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                dragView.heightAnchor.constraint(equalToConstant: dragHeight),
                dragView.widthAnchor.constraint(equalToConstant: view.frame.width / 4.0)
            ])
            
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: dragView.bottomAnchor, constant: cornerRadius - dragTopPadding - dragHeight),
                contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: view.safeAreaInsets.bottom)
            ])
            
        case .curveCloseButton:
            let cornerRadius: CGFloat = 40.0
            let btnSize: CGFloat = 25.0
            let btnTopPadding: CGFloat = 20.0
            containerView.roundSpecificCorners([.topLeft, .topRight], radius: cornerRadius)
            
            setupButton()
            
            containerView.addSubview(closeButton)
            containerView.addSubview(contentView)
            
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: btnTopPadding),
                closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: cornerRadius / 2),
                closeButton.heightAnchor.constraint(equalToConstant: btnSize),
                closeButton.widthAnchor.constraint(equalToConstant: btnSize)
            ])
            
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 5.0),
                contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: view.safeAreaInsets.bottom)
            ])
        }
    }
}
