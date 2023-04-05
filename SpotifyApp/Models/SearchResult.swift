//
//  SearchResult.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 27.03.23.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
