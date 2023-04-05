//
//  CategoriesResponse.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 26.03.23.
//

import Foundation

struct CategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}
