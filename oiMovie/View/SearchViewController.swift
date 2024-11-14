//
//  SearchViewController.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//

import UIKit
import SnapKit

class SearchViewController:  UIViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var searchCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayoutForSearch())
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .systemBackground
        collection.showsHorizontalScrollIndicator = false
        collection.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "searchCell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    func createLayoutForSearch() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            movieData = []
            searchCollectionView.reloadData()
            startLabel.alpha = 0.5
            searchCollectionView.alpha = 0
            return
        }
        startLabel.alpha = 0
        searchCollectionView.alpha = 1
        apiRequest(searchFor: searchText)
        
    }
    
    lazy var startLabel: UILabel = {
        let label = UILabel()
        label.text = "Start searching for movies"
        label.textAlignment = .center
        label.alpha = 0.5
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var topInset = 0
    var movieData: [Result] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchCollectionView.reloadData()
    }
    
    
    func setupUI() {
        view.addSubview(searchCollectionView)
        view.addSubview(startLabel)
        
        searchCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            
            
        }
        
        startLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    
    func apiRequest(searchFor: String) {
        NetworkManager.shared.loadSearch(searchFor: searchFor) { result in
            self.movieData = result
            self.searchCollectionView.reloadData()
        }
    }
    

}


extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCollectionViewCell
        let movie = movieData[indexPath.row]
        cell.conf(movie: movie)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetailViewController = MovieDetailViewController()
        let movie = movieData[indexPath.row]
        
        NetworkManager.shared.loadExternalID(movieID: movie.id) { imbdID in
            movieDetailViewController.topInset = self.topInset
            movieDetailViewController.movieID = imbdID
            movieDetailViewController.movie = MovieResult(title: movie.title, imdbID: imbdID, year: nil)
            NetworkManager.shared.loadVideo(movieID: movie.id) { result in
                let videoID = result.first!.key
                movieDetailViewController.playerView.load(withVideoId: videoID)
                self.navigationController?.pushViewController(movieDetailViewController, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topInset = Int(view.safeAreaInsets.top)
    }
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalVerticalSpacing = 10
        let itemHeight = (Int(searchCollectionView.bounds.height) - totalVerticalSpacing) / 2
        let maxWidth = Int((searchCollectionView.bounds.width - 15) / 2) 
        return CGSize(width: maxWidth, height: itemHeight)
    
    }
}

