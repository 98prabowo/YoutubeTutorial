//
//  VideoPlayerView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine
import UIKit

internal final class VideoPlayerView: UIView {
    // MARK: Type Values
    
    internal enum ScreenState: Equatable {
        case noScreen
        case normal(isLoading: Bool)
        case minimize
        case maximize(control: ButtonControl)
        
        internal enum ButtonControl: Equatable {
            case active
            case speedPicker
            case lock
            case resolution
            
            internal var notLocked: Bool {
                switch self {
                case .active:
                    return true
                case .speedPicker:
                    return true
                case .lock:
                    return false
                case .resolution:
                    return true
                }
            }
        }
        
        internal var screenButtonIcon: UIImage? {
            switch self {
            case .normal:
                return UIImage(named: "maximize")
            case .maximize:
                return UIImage(named: "normalize")
            case .noScreen, .minimize:
                return nil
            }
        }
    }
    
    // MARK: UI Components
    
    internal lazy var controlView: VideoControlView = {
        let view = VideoControlView(areaInsets: areaInsets, buttons: [.rate, .lock, .resolution])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "VideoPlayerView.controlView"
        return view
    }()
    
    private let updateResoBuffer: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.accessibilityIdentifier = "VideoPlayerView.updateResoBuffer"
        return image
    }()
    
    private var speedPicker: PlaybackSpeedView?
    
    private var resolutionPicker: PlaybackResolutionView?
    
    // MARK: Properties
    
    private lazy var asset: AVURLAsset? = {
        guard let url = URL(string: urlString) else { return nil }
        let asset: AVURLAsset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        return asset
    }()
    
    private lazy var playerItem: AVPlayerItem? = {
        guard let asset else { return nil }
        let playerItem: AVPlayerItem = AVPlayerItem(asset: asset)
        playerItem.add(videoOutput)
        return playerItem
    }()
    
    private lazy var player: AVPlayer? = {
        guard let playerItem else { return nil }
        let player = AVPlayer(playerItem: playerItem)
        return player
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        layer.contentsGravity = .resizeAspect
        return layer
    }()
    
    private var videoOutput: AVPlayerItemVideoOutput = AVPlayerItemVideoOutput(outputSettings: [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
    
    internal let screenState = CurrentValueSubject<ScreenState, Never>(.noScreen)
    
    private var currentResolution: VideoDefinition?
    
    private var resoUpdateTime: Int64 = 0
    
    private let seekDuration: Float64 = 10 // seconds
    
    private var playbackRate: Float = 1.0 // seconds
    
    private var dataCancellables = Set<AnyCancellable>()
    
    private var actionCancellables = Set<AnyCancellable>()
    
    private var streamVariants = [StreamVariant]()
    
    private let urlString: String
    
    private let areaInsets: UIEdgeInsets
    
    // MARK: Lifecycles
    
    internal init(for urlString: String, areaInsets: UIEdgeInsets) {
        self.urlString = urlString
        self.areaInsets = areaInsets
        super.init(frame: .zero)
        backgroundColor = .black
        clipsToBounds = true
        setupLayout()
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        layer.addSublayer(playerLayer)
    }
    
    private func setupLayoutNoScreen() {
        controlView.removeFromSuperview()
        updateResoBuffer.removeFromSuperview()
    }
    
    private func setupLayoutNormal() {
        controlView.removeFromSuperview()
        updateResoBuffer.removeFromSuperview()
        pinSubview(controlView)
    }
    
    private func setupLayoutMinimize() {
        controlView.removeFromSuperview()
        updateResoBuffer.removeFromSuperview()
    }
    
    private func setupLayoutMaximize() {
        updateResoBuffer.removeFromSuperview()
        controlView.removeFromSuperview()
        pinSubview(updateResoBuffer)
        pinSubview(controlView)
    }
    
    private func setupLayoutSpeedPicker() {
        speedPicker = PlaybackSpeedView(
            areaInsets: areaInsets,
            currentRate: playbackRate
        )
        speedPicker?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let speedPicker else { return }

        controlView.removeFromSuperview()
        
        addSubview(speedPicker)

        NSLayoutConstraint.activate([
            speedPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            speedPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            speedPicker.topAnchor.constraint(equalTo: topAnchor),
            speedPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        speedPicker.showPanel()
        
        speedPicker.playbackRate
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] rate in
                guard let self else { return }
                switch self.controlView.state.value {
                case .loading, .finished, .paused:
                    self.playbackRate = rate
                case .playing:
                    guard let player = self.player else { return }
                    player.rate = rate
                    self.playbackRate = rate
                }
            }
            .store(in: &speedPicker.cancellables)
        
        speedPicker.speedPickerDismissed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                
                self.speedPicker = nil
                
                switch self.screenState.value {
                case .noScreen, .minimize:
                    break
                case let .normal(isLoading):
                    self.screenState.send(.normal(isLoading: isLoading))
                    var controlState: VideoControlView.State = self.controlView.state.value
                    controlState.showControlPanel()
                    self.controlView.state.send(controlState)
                case .maximize:
                    self.screenState.send(.maximize(control: .active))
                    var controlState: VideoControlView.State = self.controlView.state.value
                    controlState.showControlPanel()
                    self.controlView.state.send(controlState)
                }
            }
            .store(in: &speedPicker.cancellables)
    }
    
    private func setupLayoutResolutionPicker() {
        guard let url = URL(string: urlString), let player else { return }
        
        let currentReso: VideoDefinition = currentResolution ?? .auto(url: url)
        var resolutions: [VideoDefinition] = streamVariants.removeDuplicate().map(\.definition)
        resolutions.insert(.auto(url: url), at: streamVariants.endIndex - 1)
        
        resolutionPicker = PlaybackResolutionView(
            areaInsets: areaInsets,
            currentReso: currentReso,
            resolutions: resolutions
        )
        resolutionPicker?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let resolutionPicker else { return }
        
        controlView.removeFromSuperview()
        
        addSubview(resolutionPicker)

        NSLayoutConstraint.activate([
            resolutionPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            resolutionPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            resolutionPicker.topAnchor.constraint(equalTo: topAnchor),
            resolutionPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        resolutionPicker.showPanel()
        
        resolutionPicker.currentReso
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] resolution in
                guard let self else { return }
                
                let currentTime: CMTime = player.currentTime()
                guard let image = self.getImageFromBuffer(for: currentTime) else { return }
                
                self.pause()
                self.updateResoBuffer.image = image
                self.replacePlayerItem(with: resolution.url)

                // Continue new payer item with previous item duration
                player.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero)
                self.currentResolution = resolution
                self.configVideoOuputBuffer()

                guard case .playing = self.controlView.state.value else { return }
                self.play()
            }
            .store(in: &resolutionPicker.cancellables)
        
        resolutionPicker.resoPickerDismissed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                
                self.resolutionPicker = nil
                
                switch self.screenState.value {
                case .noScreen, .minimize:
                    break
                case let .normal(isLoading):
                    self.screenState.send(.normal(isLoading: isLoading))
                    var controlState: VideoControlView.State = self.controlView.state.value
                    controlState.showControlPanel()
                    self.controlView.state.send(controlState)
                case .maximize:
                    self.screenState.send(.maximize(control: .active))
                    var controlState: VideoControlView.State = self.controlView.state.value
                    controlState.showControlPanel()
                    self.controlView.state.send(controlState)
                }
            }
            .store(in: &resolutionPicker.cancellables)
    }

    // MARK: Implementations
    
    private func configVideoOuputBuffer() {
        player?.currentItem?.remove(videoOutput)
        let settings = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)]
        videoOutput = AVPlayerItemVideoOutput(outputSettings: settings)
        player?.currentItem?.add(videoOutput)
    }
    
    private func replacePlayerItem(with url: URL) {
        guard let player else { return }
        let asset: AVURLAsset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let playerItem: AVPlayerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
    }
    
    private func getImageFromBuffer(for currentTime: CMTime) -> UIImage? {
        var presentationItemTime: CMTime = .zero
        guard videoOutput.hasNewPixelBuffer(forItemTime: currentTime),
              let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: &presentationItemTime) else { return nil }
        let ciImage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context: CIContext = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func bindData() {
        guard let player else { return }
        
        player.periodicTimePublisher()
            .sink { [weak self] time in
                guard let self else { return }
                
                if let item = player.currentItem {
                    let currentDuration: Float64 = CMTimeGetSeconds(item.currentTime())
                    let maxDuration: Float64 = CMTimeGetSeconds(item.duration)
                    guard !(currentDuration.isNaN || currentDuration.isInfinite),
                          !(maxDuration.isNaN || maxDuration.isInfinite) else { return }
                    self.controlView.duration.send((currentDuration, maxDuration))
                }
                
                if self.playerLayer.isReadyForDisplay,
                   player.status == .readyToPlay,
                   time.value > self.resoUpdateTime {
                    self.updateResoBuffer.image = nil
                    self.resoUpdateTime = time.value
                }
                
                guard time.value == 0 else { return }
                self.controlView.state.send(.playing(isHidden: true, source: .system))
            }
            .store(in: &dataCancellables)

        player.finishPlayPublisher()
            .sink { [weak self] in
                guard let self else { return }
                self.speedPicker?.removeFromSuperview()
                self.speedPicker = nil

                switch self.screenState.value {
                case .noScreen, .minimize:
                    break
                case let .normal(isLoading):
                    self.screenState.send(.normal(isLoading: isLoading))
                case .maximize:
                    self.screenState.send(.maximize(control: .active))
                }

                self.controlView.state.send(.finished(isHidden: false))
            }
            .store(in: &dataCancellables)

        controlView.sliderValue
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [controlView] current, _ in
                let seekTime: CMTime = CMTimeMake(value: Int64(current), timescale: 1)
                player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                guard controlView.state.value == .finished(isHidden: false) else { return }
                controlView.state.send(.playing(isHidden: false, source: .userInteraction))
                controlView.action.send(.control(action: .didTapPlayButton))
            }
            .store(in: &dataCancellables)

        NetworkManager.shared.getResolutionPublisher(from: urlString)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] variants in
                guard let self else { return }
                self.streamVariants = variants
            }
            .store(in: &dataCancellables)
    }
    
    private func bindAction() {
        tap()
            .sink { [controlView, screenState] in
                switch screenState.value {
                case .normal, .maximize:
                    var state = controlView.state.value
                    state.toggleHidden()
                    controlView.state.send(state)
                    
                case .minimize:
                    screenState.send(.normal(isLoading: false))
                    
                case .noScreen:
                    break
                }
            }
            .store(in: &actionCancellables)
        
        controlView.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .noAction:
                    break
                    
                case let .screen(screenAction):
                    switch screenAction {
                    case .didTapNormalizeButton:
                        self.screenState.send(.normal(isLoading: false))
                    case .didTapMinimizeButton:
                        self.screenState.send(.minimize)
                    case .didTapMaximizeButton:
                        self.screenState.send(.maximize(control: .active))
                    case .didTapSpeedButton:
                        self.screenState.send(.maximize(control: .speedPicker))
                    case .didTapLockButton:
                        self.screenState.send(.maximize(control: .lock))
                    case .didTapResolutionButton:
                        self.screenState.send(.maximize(control: .resolution))
                    }
                    
                case let .control(controlAction):
                    switch controlAction {
                    case .didTapPlayButton:
                        self.play()
                    case .didTapPauseButton:
                        self.pause()
                    case .didTapReplayButton:
                        self.replay()
                    case .didTapForwardButton:
                        self.goForward()
                    case .didTapBackwardButton:
                        self.goBackward()
                    }
                }
            }
            .store(in: &actionCancellables)
        
        screenState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                // Sync screen state with screen state in control view
                self.controlView.screenState.send(state)
                
                // Handle layouts and actions
                switch state {
                case .noScreen:
                    self.setupLayoutNoScreen()
                    self.pause()
                case .normal:
                    self.setupLayoutNormal()
                case .minimize:
                    self.setupLayoutMinimize()
                case .maximize(control: .active), .maximize(control: .lock):
                    self.setupLayoutMaximize()
                case .maximize(control: .speedPicker):
                    self.setupLayoutSpeedPicker()
                case .maximize(control: .resolution):
                    self.setupLayoutResolutionPicker()
                }
            }
            .store(in: &actionCancellables)
    }
    
    // MARK: Interfaces
    
    internal func stopPlaying() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer.removeFromSuperlayer()
        dataCancellables.cancelAll()
    }
    
    internal func play() {
        guard let player else { return }
        if playbackRate > 0.0 {
            player.rate = playbackRate
        }
        player.play()
        
        #if DEBUG
            print("Video url:", urlString)
        #endif
    }
    
    internal func pause() {
        guard let player else { return }
        player.pause()
    }
    
    internal func replay() {
        guard let player else { return }
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()
    }
    
    internal func goForward() {
        guard let player,
              let duration = player.currentItem?.duration else { return }
        let playerCurrentTime: Float64 = CMTimeGetSeconds(player.currentTime())
        let newTime: Float64 = playerCurrentTime + seekDuration
        guard newTime < CMTimeGetSeconds(duration) else { return }
        let time: CMTime = CMTimeMake(value: Int64(newTime), timescale: 1)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    internal func goBackward() {
        guard let player else { return }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime: Float64 = playerCurrentTime - seekDuration
        newTime = newTime < 0.0 ? 0.0 : newTime
        let time: CMTime = CMTimeMake(value: Int64(newTime), timescale: 1)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    internal func changeVideo(for urlString: String) {
        guard let url = URL(string: urlString), let player else { return }
        player.pause()
        let asset: AVURLAsset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let playerItem: AVPlayerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        #if DEBUG
            print("Video url:", urlString)
        #endif
    }
    
    internal func resizePlayerLayer(with size: CGSize) {
        if playerLayer.bounds.width > size.width ||
            playerLayer.bounds.height > size.height {
            playerLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height)
        } else {
            // Disable `CALayer` implicit animations
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            playerLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height)
            CATransaction.commit()
        }
    }
}
