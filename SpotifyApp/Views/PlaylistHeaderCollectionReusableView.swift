//
//  PlaylistHeaderCollectionReusableView.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 25.03.23.
//

import SDWebImage
import UIKit

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let followersCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    //MARK: -- INIT
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubview(playlistNameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(followersCountLabel)
        addSubview(imageView)
        addSubview(playAllButton)
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapPlayAll() {
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = height/1.7
        imageView.frame = CGRect(x: (width-imageSize)/2,
                                 y: 10,
                                 width: imageSize,
                                 height: imageSize)
        playlistNameLabel.frame = CGRect(x: 10,
                                         y: imageView.bottom+10,
                                         width: width-20,
                                         height: 25)
        descriptionLabel.frame = CGRect(x: 10,
                                        y: playlistNameLabel.bottom+5,
                                        width: width-20,
                                        height: 50)
        ownerLabel.frame = CGRect(x: 10,
                                  y: descriptionLabel.bottom+5,
                                  width: width-20,
                                  height: 20)
        followersCountLabel.frame = CGRect(x: 10,
                                           y: ownerLabel.bottom+5,
                                           width: width-20,
                                           height: 20)
        playAllButton.frame = CGRect(x: width-80,
                                     y: height-80,
                                     width: 60,
                                     height: 60)
    }
    
    func configure(with viewModel: PlaylistHeaderViewViewModel, type: HeaderType) {
        playlistNameLabel.text = viewModel.playlistName
        ownerLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.playlistDescription
        imageView.sd_setImage(with: viewModel.artworkURL, placeholderImage: UIImage(systemName: "music.quarternote.3"))
        
        guard let _count = viewModel._count else { return }
        if type == .playlist {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            guard let formattedNumber = numberFormatter.string(from: NSNumber(value: _count)) else { return }
            followersCountLabel.text = "Followers: \(formattedNumber)"
        } else {
            followersCountLabel.text = "Total tracks: \(_count)"
        }

    }
    
    enum HeaderType {
        case album
        case playlist
    }
}
