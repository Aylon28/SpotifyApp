//
//  AlbumDetailsResponse.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 25.03.23.
//

import Foundation

struct AlbumDetailsResponse: Codable {
    let album_group: String
    let album_type: String
    let external_urls: [String: String]
    let available_markets: [String]
    let id: String
    let images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
    let label: String
    let tracks: TrackResponse
}

struct TrackResponse: Codable {
    let items: [AudioTrack]
}
