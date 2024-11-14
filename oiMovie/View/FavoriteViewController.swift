//
//  FavoriteViewController.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    
    lazy var startLabel: UILabel = {
        let label = UILabel()
        label.text = "Add favorite movies"
        label.textAlignment = .center
        label.alpha = 0.5
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var movieTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "favorite")
        return table
    }()
 
    var movieData:[MovieResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Favorites"

        // Set the title display mode to automatic to allow it to shrink when scrolling
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Favorites"
        navigationItem.titleView?.alpha = 1
        loadFromCoreData()
        movieTableView.reloadData()
        
    }
    
    func setupUI() {
        view.addSubview(movieTableView)
        view.addSubview(startLabel)
        movieTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        startLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func loadFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistantContainer.viewContext
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
        do {
            let result = try context.fetch(fetch)
            var movies:[MovieResult] = []
            for data in result as! [NSManagedObject] {
                let movieID = data.value(forKey: "movieID") as! String
                let title = data.value(forKey: "title") as! String
                let posterPath = data.value(forKey: "posterPath") as! String
                let voteAverage = data.value(forKey: "voteAverage") as! Double
                let movie = MovieResult(title: title, imdbID: movieID, year: nil,rating: voteAverage, poster: posterPath)
                movies.append(movie)
            }
            movieData = movies
            if movieData.isEmpty {
                movieTableView.alpha = 0
                startLabel.alpha = 0.5
            } else {
                startLabel.alpha = 0
                movieTableView.alpha = 1
            }
            
        }
        catch {
            print("error loadCoreData")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }


}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "favorite", for: indexPath) as! MovieTableViewCell
        let movie = movieData[indexPath.row]
        cell.conf(movie: movie)
        cell.method = { [weak self] in
            self!.loadFromCoreData()
            self!.movieTableView.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailViewController = MovieDetailViewController()
        let movieID = movieData[indexPath.row].imdbID
        movieDetailViewController.movieID = movieID
        NetworkManager.shared.loadVideo(movieID: movieID) { result in
            let videoID = result.first!.key
            movieDetailViewController.playerView.load(withVideoId: videoID)
            self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        }
    }

    
}
