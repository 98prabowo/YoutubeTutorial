//
//  PlaybackSpeedView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 10/03/23.
//

import Combine
import UIKit

internal final class PlaybackSpeedView: UIView {
    // MARK: UI Components
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "PlaybackSpeedView.backgroundView"
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.accessibilityIdentifier = "PlaybackSpeedView.containerView"
        return view
    }()
    
    private let closeBtn: UIImageView = {
        let img = UIImage(systemName: "xmark")
        let imgView = UIImageView(image: img)
        imgView.tintColor = .white
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.accessibilityIdentifier = "PlaybackSpeedView.closeBtn"
        return imgView
    }()
    
    private let slider: UISlider = {
        let slider = UISlider()
        slider.alpha = 0.0
        slider.tintColor = .white
        slider.thumbTintColor = .white
        slider.maximumTrackTintColor = .systemGray
        slider.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        slider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.accessibilityIdentifier = "PlaybackSpeedView.slider"
        return slider
    }()
    
    private let speedStack: UIStackView = {
        let stack = UIStackView()
        stack.alpha = 0.0
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "PlaybackSpeedView.playbackStack"
        return stack
    }()
    
    private var closeBtnTrailingConstraint: NSLayoutConstraint?
    
    private var sliderTrailingConstraint: NSLayoutConstraint?
    
    private var sliderBottomConstraint: NSLayoutConstraint?
    
    private var speedStackTrailingConstraint: NSLayoutConstraint?
    
    private var containerHeightConstraint: NSLayoutConstraint?
    
    // MARK: Properties
    
    internal let playbackRate: CurrentValueSubject<Float, Never>
    
    internal let speedPickerDismissed = PassthroughSubject<Void, Never>()
    
    internal var cancellables = Set<AnyCancellable>()
    
    private let playbackRates: [Float]
    
    private let areaInsets: UIEdgeInsets
    
    // MARK: Lifecycles
    
    internal init(
        areaInsets: UIEdgeInsets,
        currentRate: Float = 1.0,
        playbackRates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5]
    ) {
        self.areaInsets = areaInsets.add(20.0, .vertical)
        self.playbackRates = playbackRates
        slider.minimumValue = playbackRates.first ?? 0.0
        slider.maximumValue = playbackRates.last ?? 1.0
        playbackRate = CurrentValueSubject<Float, Never>(currentRate)
        super.init(frame: .zero)
        slider.value = currentRate
        backgroundColor = .clear
        setupLayout()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        playbackRates.forEach { rate in
            let label = UILabel()
            label.text = "\(rate)x"
            label.textColor = .white
            label.font = .preferredFont(forTextStyle: .subheadline)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.accessibilityIdentifier = "PlaybackSpeedView.SpeedLabel.\(rate)x"
            
            speedStack.addArrangedSubview(label)
        }
        
        containerView.addSubview(closeBtn)
        containerView.addSubview(slider)
        containerView.addSubview(speedStack)
        
        closeBtnTrailingConstraint = closeBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -areaInsets.bottom)
        closeBtnTrailingConstraint?.priority = .defaultHigh
        closeBtnTrailingConstraint?.identifier = "PlaybackSpeedView.closeBtnTrailingConstraint"
        closeBtnTrailingConstraint?.isActive = true
        
        sliderTrailingConstraint = slider.trailingAnchor.constraint(equalTo: closeBtn.leadingAnchor, constant: -20.0)
        sliderTrailingConstraint?.priority = .defaultHigh
        sliderTrailingConstraint?.identifier = "PlaybackSpeedView.sliderTrailingConstraint"
        sliderTrailingConstraint?.isActive = true
        
        sliderBottomConstraint = slider.bottomAnchor.constraint(equalTo: speedStack.topAnchor, constant: -5.0)
        sliderBottomConstraint?.priority = .defaultHigh
        sliderBottomConstraint?.identifier = "PlaybackSpeedView.sliderBottomConstraint"
        sliderBottomConstraint?.isActive = true
        
        speedStackTrailingConstraint = speedStack.trailingAnchor.constraint(equalTo: slider.trailingAnchor)
        speedStackTrailingConstraint?.priority = .defaultHigh
        speedStackTrailingConstraint?.identifier = "PlaybackSpeedView.speedStackTrailingConstraint"
        speedStackTrailingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.0),
            closeBtn.heightAnchor.constraint(equalTo: closeBtn.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10.0),
            slider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: areaInsets.top)
        ])
        
        NSLayoutConstraint.activate([
            speedStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: areaInsets.top),
            speedStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10.0)
        ])
        
        addSubview(containerView)
    }
    
    private func setupFinishedLayout() {
        containerView.removeFromSuperview()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        addSubview(backgroundView)
        
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 100.0)
        containerHeightConstraint?.priority = .defaultHigh
        containerHeightConstraint?.identifier = "PlaybackSpeedView.containerHeightConstraint"
        containerHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.topAnchor)
        ])
    }
    
    private func dismissPanel() {
        containerView.removeFromSuperview()
        containerView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(containerView)
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.slider.alpha = 0.0
            self.speedStack.alpha = 0.0
            self.containerView.frame = CGRectMake(0.0, self.frame.height, self.frame.width, 0.0)
        } completion: { [weak self] _ in
            guard let self else { return }
            self.containerView.removeFromSuperview()
            self.removeFromSuperview()
            self.speedPickerDismissed.send()
        }
    }
    
    // MARK: Private Implementations
    
    private func bindAction() {
        slider.action([.touchUpInside, .touchUpOutside, .touchCancel])
            .sink { [slider, playbackRate] in
                let newValue: Float = Float(lroundf(slider.value * 4.0)) / 4.0
                slider.setValue(newValue, animated: true)
                playbackRate.send(newValue)
            }
            .store(in: &cancellables)
        
        backgroundView.tap()
            .sink { [weak self] in
                guard let self else { return }
                self.dismissPanel()
            }
            .store(in: &cancellables)
        
        closeBtn.tap()
            .sink { [weak self] in
                guard let self else { return }
                self.dismissPanel()
            }
            .store(in: &cancellables)
    }
    
    // MARK: Interfaces
    
    internal func showPanel() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
            self.containerView.frame = CGRectMake(0.0, self.frame.height, self.frame.width, 0.0)
        } completion: { [weak self] _ in
            guard let self else { return }
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseOut
            ) { [weak self] in
                guard let self else { return }
                self.layoutIfNeeded()
                self.slider.alpha = 1.0
                self.speedStack.alpha = 1.0
                self.containerView.frame = CGRectMake(0.0, self.frame.height - 100.0, self.frame.width, 100.0)
            } completion: { [weak self] _ in
                guard let self else { return }
                self.setupFinishedLayout()
            }
        }
        
    }
}
