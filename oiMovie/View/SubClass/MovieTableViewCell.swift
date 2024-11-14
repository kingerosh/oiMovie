//
//  MovieTableViewCell.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//

import UIKit
import SnapKit
import CoreData

class MovieTableViewCell: UITableViewCell {

    lazy var movieImage:UIImageView = {
       let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 30
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var ratingLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.backgroundColor = .green
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    private lazy var movieTitle:UILabel = {
       let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var stackView:UIStackView = {
       let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var favoriteImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "heart")
        return image
    }()
    
    private var isFavorite: Bool = false {
        
        didSet {
            favoriteImage.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        }
    }
    
    private var movie: MovieResult?
    var method: (()->Void)? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func conf(movie: MovieResult) {
        self.movie = movie
        
        self.movieImage.image = nil
        activityIndicator.startAnimating()
        
        NetworkManager.shared.fetchMovieImages(movieID: movie.imdbID) { result in
            if result.poster != nil || result.fanart != nil {
                NetworkManager.shared.RloadImage(posterPath: (result.poster ?? result.fanart)!) { data in
                    
                    self.movieImage.image = UIImage(data: data)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                self.movieImage.image = UIImage(named: "no_image")
                self.activityIndicator.stopAnimating()
            }
        }
        
        // "Rating"
        // Below code is works, but it makes api request for each movie separetly, that's why I decided to remove it.
        // But if you want Ratings to be visible re-comment it:)

//        NetworkManager.shared.fetchMovieDetails(movieID: movie.imdbID) { result in
//            self.ratingLabel.alpha = 1
//            let rating = Double(result.imdbRating ?? "0.0")!
//            self.ratingLabel.text = String(format: "%.1f", rating)
//            switch rating {
//            case 8...10:
//                self.ratingLabel.backgroundColor = #colorLiteral(red: 0.8750129342, green: 0.6924943328, blue: 0.057133995, alpha: 1)
//                self.ratingLabel.textColor = .black
//            case 7..<8:
//                self.ratingLabel.backgroundColor = #colorLiteral(red: 0.1767785549, green: 0.6384589076, blue: 0.07636176795, alpha: 1)
//                self.ratingLabel.textColor = .white
//            case 5..<7:
//                self.ratingLabel.backgroundColor = .gray
//                self.ratingLabel.textColor = .white
//            case 0..<5:
//                self.ratingLabel.backgroundColor = .red
//                self.ratingLabel.textColor = .white
//            default:
//                self.ratingLabel.backgroundColor = .gray
//                self.ratingLabel.textColor = .white
//            }
//        }
        
        movieTitle.text = movie.title
        
        
        loadFavorite(movie: movie)
    }
    
    func setupUI() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(movieImage)
        movieImage.addSubview(favoriteImage)
        movieImage.addSubview(ratingLabel)
        movieImage.addSubview(activityIndicator)
        stackView.addArrangedSubview(movieTitle)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        movieImage.snp.makeConstraints { make in
            make.height.equalTo(484)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing).offset(-15)
            make.leading.equalToSuperview().offset(15)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(movieImage)
        }
        favoriteImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(50)
            make.width.equalTo(60)
        }
        ratingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17.5)
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(35)
            make.width.equalTo(50)
        }
        
        favoriteImage.isUserInteractionEnabled = true
        movieImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        favoriteImage.addGestureRecognizer(tap)
        
        
    }
    
    @objc func tap() {
        guard let movie else {return}
        if isFavorite {
            deleteFavorite(movie: movie)
        } else {
            saveFavorite(movie: movie)
        }
        isFavorite.toggle()
        if let method {
            method()
        }
    }
    
    func saveFavorite(movie: MovieResult) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistantContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: context) else {return}
        let favorite = NSManagedObject(entity: entity, insertInto: context)
        favorite.setValue(movie.imdbID, forKey: "movieID")
        favorite.setValue(movie.title, forKey: "title")
        favorite.setValue(movie.poster ?? "", forKey: "posterPath")
        favorite.setValue(movie.rating ?? Double(0), forKey: "voteAverage")
        do {
            try context.save()
        }
        catch {
            print("error save to CoreData")
        }
    }
    
    func deleteFavorite(movie: MovieResult) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistantContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
        fetchRequest.predicate = NSPredicate(format: "movieID == %@", movie.imdbID)
        do {
            let result = try context.fetch(fetchRequest)
            if let objectDelete = result.first as? NSManagedObject {
                context.delete(objectDelete)
            }
            try context.save()
        } catch {
            print("error delete favorite")
        }
    }
    
    func loadFavorite(movie: MovieResult) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistantContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
        fetchRequest.predicate = NSPredicate(format: "movieID == %@", movie.imdbID)
        do {
            let result = try context.fetch(fetchRequest)
            if !result.isEmpty {
                isFavorite = true
            } else {
                isFavorite = false
            }
        } catch {
            
        }
    }
    
    
}
