//
//  AsyncImageView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 22/02/23.
//

import Combine
import UIKit

internal final class AsyncImageView: UIView {
    // MARK: UI Components
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let loadingView: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        return shimmer
    }()
    
    // MARK: Properties
    
    override internal var contentMode: UIView.ContentMode {
        didSet {
            imageView.contentMode = contentMode
        }
    }
    
    internal var url: String? {
        didSet {
            guard let url else { return }
            bindData(url: url)
        }
    }
    
    private var finishFetch: Bool = false
    
    private var cancellable: AnyCancellable?
    
    // MARK: Lifecycles
    
    internal init(url: String? = nil) {
        self.url = url
        super.init(frame: .zero)
        setupViews()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func layoutSubviews() {
        super.layoutSubviews()
        guard !finishFetch else { return }
        loadingView.size = bounds.size
    }
    
    // MARK: Implementations
    
    private func setupViews() {
        layer.masksToBounds = true
        pinSubview(loadingView)
    }
    
    private func bindData(url: String) {
        cancellable =  NetworkManager.shared.getImagePublisher(from: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case let .failure(error):
                    let noImage: UIImage? = UIImage(systemName: "photo")
                    self.imageView.contentMode = .scaleAspectFit
                    self.imageView.tintColor = .secondaryLabel
                    self.imageView.image = noImage
                    
                    self.loadingView.removeFromSuperview()
                    self.pinSubview(self.imageView)
                    
                    #if DEBUG
                        let id: String = self.accessibilityIdentifier ?? String(describing: Self.self)
                        print("\(id) network error: \(error.localizedDescription)")
                    #endif
                case .finished:
                    break
                }
            } receiveValue: { [weak self] image in
                guard let self else { return }
                self.imageView.image = image
                self.loadingView.removeFromSuperview()
                self.pinSubview(self.imageView)
                self.finishFetch = true
            }
    }
}
