//
//  Artist.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 23.03.23.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let external_urls: [String: String]
}
