//
//  ShowList.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/11/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import Foundation

// The JSON data gotten from the IMDb api
struct SearchResults: Codable{
    let results: [Media]
    struct Media: Codable {
        let mediaType: String?
        // Movies
        let title: String?
        let posterPath: String?
        let voteAverage: Double?
        let voteCount: Int?
        let overview: String?
        // TV Shows
        let name: String?
        // Actors and Actresses
        let profilePath: String?
        let id: Int?
    }
}
