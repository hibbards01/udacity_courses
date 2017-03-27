//
//  FavoritesTableViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/26/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - FavoritesViewController: UIViewController

class FavoritesViewController: UIViewController {

    // MARK: Properties

    var movies: [TMDBMovie] = [TMDBMovie]()
    var tmdbClient = TMDBClient.sharedInstance

    // MARK: Outlets

    @IBOutlet weak var moviesTableView: UITableView!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // create and set the logout button
        parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))

        // Grab the movies that have been favorite.
        tmdbClient.getFavoriteMovies { favoriteMovies in
            // Make sure there are movies
            if let favoriteMovies = favoriteMovies {
                self.movies = favoriteMovies

                DispatchQueue.main.async {
                    self.moviesTableView.reloadData()
                }
            } else {
                self.showAlert(with: "Unable to grab favorite movies", and: "Please try again later.")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Logout

    func logout() {
        dismiss(animated: true, completion: nil)
    }

    /**
        Show an alert to the user.

        @param title   The title of the alert.
        @param message The message to display to the user.
     */
    private func showAlert(with title: String, and message: String) {
        // Create the alert.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))

        // Show the alert on the main thread.
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

// MARK: - FavoritesViewController: UITableViewDelegate, UITableViewDataSource

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        /* Get cell type */
        let cellReuseIdentifier = "FavoriteTableViewCell"
        let movie = movies[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!

        /* Set cell defaults */
        cell?.textLabel!.text = movie.title
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        cell?.imageView!.image = UIImage(named: "Film")

        // Grab the actual image if there is one from the database.
        movie.getRowImage { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell?.imageView!.image = UIImage(data: image)
                }
            }
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movies[(indexPath as NSIndexPath).row]
        navigationController!.pushViewController(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
