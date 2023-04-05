//
//  TrackWithoutImageCollectionViewCell.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 26.03.23.
//

import Foundation
import UIKit

class TrackWithoutImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackWithoutImageCollectionViewCell"
    
    private let trackNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(trackNameLabel)
        contentView.clipsToBounds = true
        contentView.addSubview(artistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        artistNameLabel.frame = CGRect(x: 10,
                                       y: contentView.height/2,
                                       width: contentView.width-15,
                                       height: contentView.height/2)
        
        trackNameLabel.frame = CGRect(x: 10,
                                      y: 2,
                                      width: contentView.width-15,
                                      height: contentView.height/2)
    
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    func configure(with viewModel: AlbumCollectionViewCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        
        if !viewModel.playable {
            trackNameLabel.textColor = .secondaryLabel
        }
    }
}
