//
//  RMovieDetail.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//
//  Model for Rapid api

import Foundation

// MARK: - RMovieDetail
struct RMovieDetail: Codable {
    let title, description, tagline, year: String?
    let releaseDate, imdbID, imdbRating, voteCount: String?
    let popularity, rated: String?
    let youtubeTrailerKey: String?
    let runtime: Int?
    let genres: [String]?
    let stars, directors, countries: [String]?
    let language: [String]?
    let status, statusMessage: String?

    enum CodingKeys: String, CodingKey {
        case title, description, tagline, year
        case releaseDate = "release_date"
        case imdbID = "imdb_id"
        case imdbRating = "imdb_rating"
        case voteCount = "vote_count"
        case popularity
        case youtubeTrailerKey = "youtube_trailer_key"
        case rated, runtime, genres, stars, directors, countries, language, status
        case statusMessage = "status_message"
    }
}
