//
//  RImage.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//
//  Model for Rapid api

import Foundation

// MARK: - RImage
struct RImage: Codable {
    let title, imdb: String?
    let poster, fanart: String?
    let status, statusMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case imdb = "IMDB"
        case poster, fanart, status
        case statusMessage = "status_message"
    }
}
