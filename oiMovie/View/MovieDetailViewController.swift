//
//  MovieDetailViewController.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//

import UIKit
import SnapKit
import YouTubeiOSPlayerHelper

class MovieDetailViewController: UIViewController {
    
    private lazy var scrollView:UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    lazy var playerView: YTPlayerView = {
        let player = YTPlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()

    private lazy var movieImage:UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.5, 1.0]
        return gradient
    }()
    
    private lazy var movieTitle:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var realiseStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack  = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    private lazy var realiseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private lazy var genreCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .black
        collection.showsHorizontalScrollIndicator = false
        collection.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: "genre")
        return collection
    
    }()
    
    private lazy var starStackView:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    
    private lazy var ratingLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private lazy var countRatingLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var overviewView:UIView = {
        let overview = UIView()
        overview.translatesAutoresizingMaskIntoConstraints = false
        overview.backgroundColor = .systemBackground
        return overview
    }()
    
    private lazy var overviewTextLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    var movieID = ""
    private var genre:[String] = []
    private var movieData: RMovieDetail?
    var movie: MovieResult?
    private var casts:[String] = []
    private var directors:[String] = []
    
    private lazy var castLabel:UILabel = {
        let label = UILabel()
        label.text = "Cast"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var castCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .systemBackground
        collection.showsHorizontalScrollIndicator = false
        collection.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: "cast")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var castView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var directorLabel:UILabel = {
        let label = UILabel()
        label.text = "Directors"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var directorCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .systemBackground
        collection.showsHorizontalScrollIndicator = false
        collection.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: "director")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var directorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
        apiRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame when screen size changes
        gradientLayer.frame = movieImage.bounds
    }
    
    func content() {
        guard let movieData else {return}
        genre = movieData.genres ?? []
        if genre != [] {
            genreCollectionView.alpha = 1
            genreCollectionView.reloadData()
        } else {
            genreCollectionView.alpha = 0
        }
        movieTitle.text = movieData.title
        realiseLabel.text = "Release date \(movieData.releaseDate ?? "not found")"
        
        NetworkManager.shared.fetchMovieImages(movieID: movieID) { result in
            if result.poster != nil || result.fanart != nil {
                NetworkManager.shared.RloadImage(posterPath: (result.poster ?? result.fanart)!) { data in
                    self.movieImage.image = UIImage(data: data)
                }
            } else {
                self.movieImage.image = UIImage(named: "no_image")
            }
        }
        
        setStar(rating: Double(movieData.imdbRating ?? "0.0")!)
        ratingLabel.text = String(format: "%.1f/10", Double(movieData.imdbRating ?? "0.0")!)
        countRatingLabel.text = "\(movieData.voteCount ?? "0") votes"
        overviewTextLabel.text = movieData.description
    }
    
    func setupUI() {
        view.addSubview(scrollView)
        
        [movieImage,infoView,overviewView,playerView,castView,directorView].forEach {
            scrollView.addSubview($0)
        }
        
        [movieTitle,realiseStackView,ratingStackView].forEach {
            infoView.addSubview($0)
        }
        
        [castLabel,castCollectionView].forEach{
            castView.addSubview($0)
        }
        
        [directorLabel,directorCollectionView].forEach{
            directorView.addSubview($0)
        }
        
        [overviewTextLabel].forEach {
            overviewView.addSubview($0)
        }
        
        [realiseLabel,genreCollectionView].forEach {
            realiseStackView.addArrangedSubview($0)
        }
        
        [starStackView, ratingLabel, countRatingLabel].forEach {
            ratingStackView.addArrangedSubview($0)
        }
        ratingStackView.setCustomSpacing(0, after: ratingLabel)
        
        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        

        movieImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(424)
            make.width.equalTo(view.frame.width)
        }
        
        movieImage.layer.addSublayer(gradientLayer)
                
        infoView.snp.makeConstraints { make in
                make.top.equalTo(movieImage.snp.bottom)
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                make.bottom.equalTo(ratingStackView.snp.bottom).offset(10)
            }
        
        movieTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        
        realiseStackView.snp.makeConstraints { make in
            make.top.equalTo(movieTitle.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
        }
        ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(movieTitle.snp.bottom).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-15)
        }
        genreCollectionView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview()
        }
        realiseLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        overviewView.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
        }

        overviewTextLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-30)
        }
        
        playerView.snp.makeConstraints { make in
            make.top.equalTo(overviewView.snp.bottom)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalTo(castView.snp.top).offset(-10)
        }

        castView.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.bottom).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
            make.bottom.equalTo(directorView.snp.top)
        }
        castLabel.snp.makeConstraints { make in
            make.top.equalTo(castView.snp.top)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        castCollectionView.snp.makeConstraints { make in
            make.top.equalTo(castLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
            make.bottom.equalTo(castView.snp.bottom).offset(-10)
        }
        
        directorView.snp.makeConstraints { make in
            make.top.equalTo(castView.snp.bottom).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        directorLabel.snp.makeConstraints { make in
            make.top.equalTo(directorView.snp.top)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        directorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(directorLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
            make.bottom.equalTo(directorView.snp.bottom).offset(-10)
        }
    }
    
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
    private func apiRequest() {
        NetworkManager.shared.fetchMovieDetails(movieID: movieID) { movie in
            self.movieData = movie
            self.casts = movie.stars ?? []
            self.directors = movie.directors ?? []
            self.castCollectionView.reloadData()
            self.directorCollectionView.reloadData()
            self.content()
        }
    }
    
    private func setStar(rating: Double) {
        
        if rating >= 1 && rating < 10 {
            
            let fillStar: Int = Int(rating / 2)
            let halfStar: Bool = Int(rating) % 2 == 1
            
            for _ in 1...fillStar {
                let fillStarImageView = UIImageView(image: UIImage(named: "fill"))
                fillStarImageView.snp.makeConstraints { make in
                    make.height.equalTo(20)
                    make.width.equalTo(20)
                    starStackView.addArrangedSubview(fillStarImageView)
                }
            }
            if halfStar {
                let halfStarImageView = UIImageView(image: UIImage(named: "half_fill"))
                halfStarImageView.snp.makeConstraints { make in
                    make.height.equalTo(20)
                    make.width.equalTo(20)
                    starStackView.addArrangedSubview(halfStarImageView)
                }
            }
            let emptyStar = 5 - fillStar - (halfStar ? 1:0)
            for _ in 1...emptyStar {
                let emptyStarImageView = UIImageView(image: UIImage(named: "not_fill"))
                emptyStarImageView.snp.makeConstraints { make in
                    make.height.equalTo(20)
                    make.width.equalTo(20)
                    starStackView.addArrangedSubview(emptyStarImageView)
                }
            }
        } else if rating == 10 {
            for _ in 1...5 {
                let emptyStarImageView = UIImageView(image: UIImage(named: "fill"))
                emptyStarImageView.snp.makeConstraints { make in
                    make.height.equalTo(20)
                    make.width.equalTo(20)
                    starStackView.addArrangedSubview(emptyStarImageView)
                }
            }
        } else {
            for _ in 1...5 {
                let emptyStarImageView = UIImageView(image: UIImage(named: "not_fill"))
                emptyStarImageView.snp.makeConstraints { make in
                    make.height.equalTo(20)
                    make.width.equalTo(20)
                    starStackView.addArrangedSubview(emptyStarImageView)
                }
            }
        }
    }
    
}
extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == castCollectionView {
            casts.count
        } else if collectionView == genreCollectionView {
            genre.count
        } else {
            directors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == castCollectionView {
            let cell = castCollectionView.dequeueReusableCell(withReuseIdentifier: "cast", for: indexPath) as! CastCollectionViewCell
            let cast = casts[indexPath.row]
            cell.conf(cast: cast)
            return cell
        } else if collectionView == genreCollectionView {
            let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: "genre", for: indexPath) as! GenreCollectionViewCell
            let genre = genre[indexPath.row]
            cell.label.text = genre
            return cell
        } else {
            let cell = directorCollectionView.dequeueReusableCell(withReuseIdentifier: "director", for: indexPath) as! CastCollectionViewCell
            let director = directors[indexPath.row]
            cell.conf(cast: director, fontSize: 14)
            return cell
        }
    }
    
    
}
extension MovieDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == genreCollectionView {
            let label = UILabel()
            let genre = genre[indexPath.row]
            label.text = genre
            label.sizeToFit()
            return CGSize(width: label.frame.width + 20, height: 30)
        } else if collectionView == castCollectionView {
            let totalVerticalSpacing = 2 * 10 // 2 gaps for 3 rows
            let itemHeight = (Int(castCollectionView.bounds.height) - totalVerticalSpacing) / 3
            let maxWidth = 170 // width for each item
            return CGSize(width: maxWidth, height: itemHeight)
        } else {
            let totalVerticalSpacing = 0 // 0 gap for 1 rows
            let itemHeight = (Int(directorCollectionView.bounds.height) - totalVerticalSpacing) / 1
            let maxWidth = 170 // width for each item
            return CGSize(width: maxWidth, height: itemHeight)
        }
    }
}
