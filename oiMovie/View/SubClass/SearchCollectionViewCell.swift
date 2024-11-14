//
//  SearchCollectionViewCell.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 14.11.2024.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    private lazy var movieImage:UIImageView = {
       let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 15
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
        return label
    }()
    
    private lazy var movieTitle:UILabel = {
       let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        return title
    }()
    
    private lazy var stackView:UIStackView = {
       let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        stack.axis = .vertical
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var movie: Result?

    func conf(movie: Result) {
        self.movie = movie
        
        self.movieImage.image = nil
        activityIndicator.startAnimating()
        
        NetworkManager.shared.loadImage(posterPath: movie.posterPath) { data in
            self.movieImage.image = UIImage(data: data)
            self.activityIndicator.stopAnimating()
        }
        movieTitle.text = movie.title
        ratingLabel.text = String(format: "%.1f", movie.voteAverage)
        switch movie.voteAverage {
        case 8...10:
            ratingLabel.backgroundColor = #colorLiteral(red: 0.8750129342, green: 0.6924943328, blue: 0.057133995, alpha: 1)
            ratingLabel.textColor = .black
        case 7..<8:
            ratingLabel.backgroundColor = #colorLiteral(red: 0.1767785549, green: 0.6384589076, blue: 0.07636176795, alpha: 1)
            ratingLabel.textColor = .white
        case 5..<7:
            ratingLabel.backgroundColor = .gray
            ratingLabel.textColor = .white
        case 0..<5:
            ratingLabel.backgroundColor = .red
            ratingLabel.textColor = .white
        default:
            ratingLabel.backgroundColor = .gray
            ratingLabel.textColor = .white
        }
        
        
    }
    
    func setupUI() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(movieImage)
        movieImage.addSubview(ratingLabel)
        movieImage.addSubview(activityIndicator)
        stackView.addArrangedSubview(movieTitle)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        movieImage.snp.makeConstraints { make in
            make.height.equalTo(282)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(movieImage)
        }
        ratingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17.5)
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(35)
            make.width.equalTo(50)
        }
        

        
        
    }
    
}
