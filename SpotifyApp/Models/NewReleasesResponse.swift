//
//  NewReleasesResponse.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 24.03.23.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items: [Album]
}
