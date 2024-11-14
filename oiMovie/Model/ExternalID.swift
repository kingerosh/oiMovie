//
//  ExternalID.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//
// Model for TMDB api

import Foundation


// MARK: - ExternalID
struct ExternalID: Codable {
    let id: Int
    let imdbID: String
    let instagramID, twitterID, wikidataID, facebookID: String?

    enum CodingKeys: String, CodingKey {
        case id
        case imdbID = "imdb_id"
        case wikidataID = "wikidata_id"
        case facebookID = "facebook_id"
        case instagramID = "instagram_id"
        case twitterID = "twitter_id"
    }
}
