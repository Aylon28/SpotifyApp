//
//  PlaybackPresenter.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 27.03.23.
//

import AVFoundation
import Foundation
import UIKit

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var artworkURL: URL? { get }
}

final class PlaybackPresenter {
    static let shared = PlaybackPresenter()
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    var savedQueue = [AudioTrack]()
    var indexInQueue = 0
    
    var playerVC: PlayerViewController?
    
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if let _ = self.playerQueue, !tracks.isEmpty {
            return tracks[songIndex]
        }
        return nil
    }
    var songIndex = 0 {
        didSet {
            if songIndex >= maxSongCount {
                songIndex = maxSongCount - 1
            }
        }
    }
    var maxSongCount = 0
    
    var timer = Timer()
    var songPlaying: String?
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        guard let url = URL(string: track.preview_url ?? "") else { return }
        
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        playerQueue = nil
        
        let vc = PlayerViewController()
        vc.dataSourse = self
        vc.delegate = self
        vc.title = track.name
        vc.track = track
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        guard !tracks.isEmpty else { return }
        
        savedQueue = tracks
        maxSongCount = tracks.count
        songPlaying = tracks[0].id
        
        self.tracks = tracks
        self.track = nil
        player = nil
        
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        })
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkSong), userInfo: nil, repeats: true)
        
        let vc = PlayerViewController()
        vc.dataSourse = self
        vc.delegate = self
        self.playerVC = vc
        viewController.present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func checkSong() {
        guard let playingItemsCount = playerQueue?.items().count else { return }
        let currentSongIndex = maxSongCount - playingItemsCount
        if currentSongIndex != songIndex {
            songIndex = currentSongIndex
            playerVC?.refreshUI()
        }
        
    }

}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var artworkURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
        
        if let player = playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapBackward() {
        if !tracks.isEmpty {
            self.playerQueue = AVQueuePlayer(items: savedQueue.compactMap {
                guard let url = URL(string: $0.preview_url ?? "") else {
                    return nil
                }
                return AVPlayerItem(url: url)
            })
            self.playerQueue?.play()
        }
        songIndex = 0
        songPlaying = tracks[0].id
        playerVC?.refreshUI()
    }
    
    func didTapForward() {
        if !tracks.isEmpty {
            playerQueue?.advanceToNextItem()
            songIndex += 1
        }
        playerVC?.refreshUI()
    }
    
    func didSlideSlider(_ value: Float) {
        if let player = player {
            player.volume = value
        } else if let player = playerQueue {
            player.volume = value
        }
    }
}
