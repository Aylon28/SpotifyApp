//
//  PlayerViewController.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 23.03.23.
//

import SDWebImage
import UIKit

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapBackward()
    func didTapForward()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {
    weak var dataSourse: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    public var track: AudioTrack?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBackground
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configureBarButtons()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        controlsView.frame = CGRect(
            x: 10,
            y: imageView.bottom+10,
            width: view.width-20,
            height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15)
    }
    
    private func configure() {
        imageView.sd_setImage(with: dataSourse?.artworkURL)
        controlsView.configure(with: PlayerControlsViewViewModel(title: dataSourse?.songName, subtitle: dataSourse?.subtitle))
    }
    
    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        ]
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapAdd() {
        let actionSheet = UIAlertController(title: track?.name,
                                            message: "Add to playlist?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { [weak self] playlist in
                    guard let track = self?.track else { return }
                    APICaller.shared.addTrackToPlaylist(track: track, playlist: playlist) { success in
                        if success {
                            
                        }
                    }
                }
                vc.title = "Select playlist"
                self?.present(UINavigationController(rootViewController: vc), animated: true)
            }
        })
        present(actionSheet, animated: true)
    }
    
    @objc private func didTapAction() {
        guard let urlString = URL(string: track?.external_urls["spotify"] ?? "\(track?.name ?? "") by \(track?.artists.first?.name ?? "")") else { return }
        let vc = UIActivityViewController(activityItems: ["Check out this song! ", urlString],
                                          applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func refreshUI() {
        configure()
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
}
