//
//  VideoControllerView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine
import UIKit

internal final class VideoControllerView: UIView {
    // MARK: Type Values
    
    internal enum State: Equatable {
        case loading
        case playing(isHidden: Bool)
        case paused(isHidden: Bool)
        case finished(isHidden: Bool)
    }
    
    internal enum Action: Equatable {
        case didTapPlayButton
        case didTapPauseButton
        case didTapReplayButton
    }
    
    // MARK: UI Components
    
    private let loadingView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.startAnimating()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    private let pauseButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "pause.fill")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: Properties
    
    internal let state = CurrentValueSubject<State, Never>(.loading)
    
    internal let action = PassthroughSubject<Action, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .videoControllerBackground
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func layoutLoadingView() {
        pauseButton.removeFromSuperview()
        addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func layoutPauseButton() {
        loadingView.removeFromSuperview()
        addSubview(pauseButton)
        NSLayoutConstraint.activate([
            pauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            pauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            pauseButton.widthAnchor.constraint(equalToConstant: 50.0),
            pauseButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
    }
    
    // MARK: Implementations
    
    private func bindData() {
        state
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .loading:
                    self.backgroundColor = .videoControllerBackground
                    self.loadingView.startAnimating()
                    self.layoutLoadingView()
                    
                case let .playing(isHidden):
                    self.loadingView.stopAnimating()
                    if isHidden {
                        self.backgroundColor = .clear
                    } else {
                        self.backgroundColor = .videoControllerBackground
                        self.pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                        self.layoutPauseButton()
                    }
                    
                case let .paused(isHidden):
                    self.loadingView.stopAnimating()
                    if isHidden {
                        self.backgroundColor = .clear
                    } else {
                        self.backgroundColor = .videoControllerBackground
                        self.pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                        self.layoutPauseButton()
                    }
                    
                case let .finished(isHidden):
                    self.loadingView.stopAnimating()
                    if isHidden {
                        self.backgroundColor = .clear
                    } else {
                        self.backgroundColor = .videoControllerBackground
                        self.pauseButton.setImage(UIImage(systemName: "gobackward"), for: .normal)
                        self.layoutPauseButton()
                    }
                }
                print(state)
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        pauseButton.action()
            .sink { [weak self] in
                guard let self else { return }
                switch self.state.value {
                case .loading:
                    return
                case let .playing(isHidden):
                    guard !isHidden else { return }
                    self.state.send(.paused(isHidden: false))
                    self.action.send(.didTapPlayButton)
                case .paused:
                    self.state.send(.playing(isHidden: false))
                    self.action.send(.didTapPauseButton)
                case .finished:
                    self.state.send(.playing(isHidden: true))
                    self.action.send(.didTapReplayButton)
                }
            }
            .store(in: &cancellables)
    }
}
