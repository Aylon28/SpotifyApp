//
//  UserProfile.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 23.03.23.
//

import Foundation


struct UserProfile: Codable {
    let country: String
    let display_name: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let images: [APIImage]
}
