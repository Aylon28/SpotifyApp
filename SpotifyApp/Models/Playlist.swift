//
//  Playlist.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 23.03.23.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
    var followers: Int?
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
