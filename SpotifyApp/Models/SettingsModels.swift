//
//  SettingsModels.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 24.03.23.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
