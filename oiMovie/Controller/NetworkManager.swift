//
//  NetworkManager.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    
    
    
    private lazy var urlComponent:URLComponents = {
        // TMBD api url component
        var component = URLComponents()
        component.host = "api.themoviedb.org"
        component.scheme = "https"
        component.queryItems = [
            URLQueryItem(name: "api_key", value: "d351d913d674bd98da28dea154905f25")
        ]
        
        return component
    }()
    
    private lazy var urlComponent2: URLComponents = {
        // RAPID api url component
        var component = URLComponents()
        component.host = "movies-tv-shows-database.p.rapidapi.com"
        component.scheme = "https"
        return component
    }()

    // Shared HTTP headers for all requests
    private let defaultHeaders: HTTPHeaders = [
        "x-rapidapi-key": "d4a594aff1mshb07dc0badf6df9ap13333ajsn1fe6e5846dae",
        "x-rapidapi-host": "movies-tv-shows-database.p.rapidapi.com"
    ]
    
    // RAPID Api Functions
    
    func fetchMovies(theme: theme, completion: @escaping ([MovieResult]) -> Void) {
        urlComponent2.path = "/"
        urlComponent2.queryItems = [
            URLQueryItem(name: "page", value: "1")
        ]
        
        guard let url = urlComponent2.url else { return }
        
        // Add specific header for this request type
        var headers = defaultHeaders
        let value = "get-\(theme.rawValue)-movies"
        headers.add(name: "Type", value: value)
        headers.add(name: "Cache-Control", value: "no-cache")
        
        // Perform the request
        AF.request(url, headers: headers).responseDecodable(of: TrendingMovies.self) { response in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    completion(data.movieResults)
                }
            case .failure(let error):
                print("Error fetching trending movies: \(error)")
            }
        }
    }
    
    func fetchMovieDetails(movieID: String, completion: @escaping (RMovieDetail) -> Void) {
        urlComponent2.path = "/"
        urlComponent2.queryItems = [
            URLQueryItem(name: "movieid", value: movieID)
        ]
        
        guard let url = urlComponent2.url else { return }
        
        // Add specific header for this request type
        var headers = defaultHeaders
        headers.add(name: "Type", value: "get-movie-details")
        headers.add(name: "Cache-Control", value: "no-cache")
        
        // Perform the request
        AF.request(url, headers: headers).responseDecodable(of: RMovieDetail.self) { response in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    completion(data)
                }
            case .failure(let error):
                print("Error fetching movie details: \(error)")
            }
        }
    }
    
    func fetchMovieImages(movieID: String, completion: @escaping (RImage) -> Void) {
        urlComponent2.path = "/"
        urlComponent2.queryItems = [
            URLQueryItem(name: "movieid", value: movieID)
        ]

        guard let url = urlComponent2.url else { return }
        
        // Add specific header for this request type
        var headers = defaultHeaders
        headers.add(name: "Type", value: "get-movies-images-by-imdb")
        
        // Perform the request
        AF.request(url, headers: headers).responseDecodable(of: RImage.self) { response in
            switch response.result {
            case .success(let imageData):
                DispatchQueue.main.async {
                    completion(imageData)
                }
            case .failure(let error):
                print("Error fetching images: \(error)")
            }
        }
    }
    
    func RloadImage(posterPath:String, complition: @escaping (Data)-> Void) {
        guard let url = URL(string: posterPath) else {return}
        AF.request(url).response { data in
            guard let result = data.data else {return}
            DispatchQueue.main.async {
                complition(result)
            }
        }
    }
    
    
    // TMBD Api Functions
    
    private let urlImage:String = "https://image.tmdb.org/t/p/w500/"
    
    func loadSearch(searchFor: String, completion: @escaping ([Result]) -> Void) {
        urlComponent.path = "/3/search/movie"
        
        // Set query parameters
        urlComponent.queryItems?.append(URLQueryItem(name: "query", value: searchFor))
        
        guard let url = urlComponent.url else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        DispatchQueue.global().async {
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error in data task: \(error)")
                    return
                }
                guard let data = data else { return }
                do {
                    let movie = try JSONDecoder().decode(Movie.self, from: data)
                    DispatchQueue.main.async {
                        completion(movie.results)
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
            task.resume()
        }
    }
    
    func loadExternalID(movieID:Int, complition: @escaping (String)->Void){
        urlComponent.path = "/3/movie/\(movieID)/external_ids"
        guard let url = urlComponent.url else {return}
        AF.request(url).responseDecodable(of: ExternalID.self) { result in
            if let ids = try? result.result.get() {
                DispatchQueue.main.async {
                    complition(ids.imdbID)
                }
            }
        }
    }

    func loadImage(posterPath:String, complition: @escaping (Data)-> Void) {
        guard let url = URL(string: urlImage+posterPath) else {return}
        AF.request(url).response { data in
            guard let result = data.data else {return}
            DispatchQueue.main.async {
                complition(result)
            }
        }
    }
    
    func loadVideo(movieID: String, complition: @escaping ([ResultV])-> Void) {
        // uses imbdb EXTERNAL ID to load from movieDB
        urlComponent.path = "/3/movie/\(movieID)/videos"
        urlComponent.queryItems?.append(URLQueryItem(name: "external_id", value: movieID))

        guard let url = urlComponent.url else {return}
        AF.request(url).responseDecodable(of: Video.self) { result in
            if let videos = try? result.result.get() {
                DispatchQueue.main.async {
                    complition(videos.results)
                }
            }
        }
    }
    
    func loadVideo(movieID: Int, complition: @escaping ([ResultV])-> Void) {
        // CLASSIC MOVIEDB
        urlComponent.path = "/3/movie/\(movieID)/videos"
        guard let url = urlComponent.url else {return}
        AF.request(url).responseDecodable(of: Video.self) { result in
            
            if let videos = try? result.result.get() {
                DispatchQueue.main.async {
                    complition(videos.results)
                }
            }
        }
    }
}
