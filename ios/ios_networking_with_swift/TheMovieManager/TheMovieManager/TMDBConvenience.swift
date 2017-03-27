//
//  TMDBConvenience.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension TMDBClient {
    // MARK: GET Convenience Methods

    /**
        Get all their favorite movies.
     */
    func getFavoriteMovies(_ completionHandlerForFavMovies: @escaping (_ result: [TMDBMovie]?) -> Void) {

        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        let params = [
                ParameterKeys.ApiKey: Constants.ApiKey as AnyObject,
                ParameterKeys.SessionID: sessionID as AnyObject
        ]

        /* 2. Make the request */
        if let userID = userID {
            service.send(to: Constants.ApiHost, at: URLPath.getFavorite(userID).toString, with: params, returnJSON: true) { success, json, data, error in
                // Check to see if it was a success or not.
                var movies: [TMDBMovie]? = nil
                if success {
                    // Now grab the results of the json file.
                    if let results = json?["results"] as? [[String: AnyObject]] {
                        movies = TMDBMovie.moviesFromResults(results)
                    } else {
                        print("Error in request. JSON did not return the movie results. Here is the JSON: \(json)")
                    }
                } else {
                    if let error = error {
                        print("Error in getting their favorite movies: \(error.localizedDescription)")
                    }
                }

                completionHandlerForFavMovies(movies)
            }
        } else {
            print("Error no userID provided in client.")
            completionHandlerForFavMovies(nil)
        }
    }

    func getWatchlistMovies(_ completionHandlerForWatchlist: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) {

        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */

    }

    func getMoviesForSearchString(_ searchString: String, completionHandlerForMovies: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {

        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */
        return nil
    }

    func getConfig(_ completionHandlerForConfig: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {

        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */

    }

    // MARK: POST Convenience Methods

    func postToFavorites(_ movie: TMDBMovie, favorite: Bool, completionHandlerForFavorite: @escaping (_ result: Int?, _ error: NSError?) -> Void)  {

        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */

    }

    func postToWatchlist(_ movie: TMDBMovie, watchlist: Bool, completionHandlerForWatchlist: @escaping (_ result: Int?, _ error: NSError?) -> Void) {

        /* 1. Specify parameters, the API method, and the HTTP body (if POST) */
        /* 2. Make the request */
        /* 3. Send the desired value(s) to completion handler */

    }
}
