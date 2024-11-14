//
//  TrendingMovies.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//
//  Model for Rapid api

import Foundation

// MARK: - TrendingMovies
struct TrendingMovies: Codable {
    let movieResults: [MovieResult]
    let results: Int
    let totalResults, status, statusMessage: String

    enum CodingKeys: String, CodingKey {
        case movieResults = "movie_results"
        case results
        case totalResults = "Total_results"
        case status
        case statusMessage = "status_message"
    }
}

// MARK: - MovieResult
struct MovieResult: Codable {
    let title, imdbID: String
    let year: String?
    var rating: Double?
    var poster: String?

    enum CodingKeys: String, CodingKey {
        case title, year, rating, poster
        case imdbID = "imdb_id"
    }
}
