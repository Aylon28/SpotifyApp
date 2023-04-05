//
//  PlaylistDetailsResponse.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 5.04.23.
//

import Foundation

struct PlaylistDetailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let followers: Followers
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
    let tracks: PlaylistTracksResponse
}

struct Followers: Codable {
    let total: Int
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}
