//
//  VideoCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import Combine
import UIKit

internal final class VideoCell: BaseCell {
    // MARK: UI Components
    
    private let loadingCell: VideoCellLoading = {
        let loading = VideoCellLoading()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.accessibilityIdentifier = "VideoCell.loadingCell"
        return loading
    }()
    
    private let contentCell: VideoCellContent = {
        let content = VideoCellContent()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.accessibilityIdentifier = "VideoCell.contentCell"
        return content
    }()
    
    // MARK: Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Layouts
    
    override internal func setupViews() {
        contentView.pinSubview(loadingCell)
    }
    
    internal func setupCell(_ video: Video) {
        Publishers.Zip(
            NetworkManager.shared.getImageURLPublisher(from: video.thumbnailImageName),
            NetworkManager.shared.getImageURL(from: video.channel.profileImageName)
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case let .failure(error):
                print("\(error.localizedDescription)")
            case .finished:
                break
            }
        } receiveValue: { [weak self] thumbnailImage, profileImage in
            guard let self else { return }
            self.loadingCell.removeFromSuperview()
            self.contentCell.setupCell(
                title: video.title,
                subtitle: video.subtitle,
                thumbnailImage: thumbnailImage,
                profileImage: profileImage
            )
            self.contentView.pinSubview(self.contentCell)
        }
        .store(in: &cancellables)
    }
}
