//
//  RecommendationsResponse.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 24.03.23.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
