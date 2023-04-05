//
//  UserAlbumsResponse.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 5.04.23.
//

import Foundation

struct UserAlbumsResponse: Codable {
    let items: [AlbumResponse]
}

struct AlbumResponse: Codable {
    let album: Album
}
