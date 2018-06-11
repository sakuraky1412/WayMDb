//
//  ShowList.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/11/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import Foundation

// The JSON data gotten from the IMDb api
struct ShowList: Codable{
    let results: [Show]
    // Movie and TV Shows
    struct Show: Codable {
        // let label: String
        let title: String?
        let posterPath: String?
        let voteAverage: Double?
        let voteCount: Int?
        let overview: String?
        
        private enum CodingKeys: String, CodingKey {
            case title
            case posterPath = "poster_path"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
            case overview
        }
    }
}
