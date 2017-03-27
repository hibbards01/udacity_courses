//
//  TMDBMovie.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

// MARK: - TMDBMovie
import Foundation

class TMDBMovie {

    // MARK: Properties

    let title: String
    let id: Int
    let posterPath: String?
    let releaseYear: String?
    private var rowImage: Data?
    private var detailImage: Data?

    // MARK: Initializers

    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        title = dictionary[TMDBClient.JSONResponseKeys.MovieTitle] as! String
        id = dictionary[TMDBClient.JSONResponseKeys.MovieID] as! Int
        posterPath = dictionary[TMDBClient.JSONResponseKeys.MoviePosterPath] as? String
        rowImage = nil
        detailImage = nil

        if let releaseDateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String, releaseDateString.isEmpty == false {
            releaseYear = releaseDateString.substring(to: releaseDateString.characters.index(releaseDateString.startIndex, offsetBy: 4))
        } else {
            releaseYear = ""
        }
    }

    static func moviesFromResults(_ results: [[String:AnyObject]]) -> [TMDBMovie] {

        var movies = [TMDBMovie]()

        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            movies.append(TMDBMovie(dictionary: result))
        }

        return movies
    }

    /**
        Get the row image. This provides a closure if it needs to grab from the Internet async.
     */
    func getRowImage(_ completion: @escaping (Data?) -> Void) {
        if let rowImage = rowImage {
            completion(rowImage)
        } else {
            // Grab the image from the Internet.
            getImage(for: true) { data in
                self.rowImage = data
                completion(self.rowImage)
            }
        }
    }

    /**
        Get detail image

        @param completion A closure for when it has grabbed the image.
     */
    func getDetailImage(_ completion: @escaping (Data?) -> Void) {
        if let detailImage = detailImage {
            completion(detailImage)
        } else {
            // Grab the image from the Internet.
            getImage(for: false) { data in
                self.detailImage = data
                completion(self.detailImage)
            }
        }
    }

    /**
        This will grab the images.

        @param rowImage Boolean to grab the row image or the detail image.
     */
    private func getImage(for rowImage: Bool, _ completion: @escaping (Data?) -> Void) {
        // Get the ClientService
        let service = ClientService()

        // Make sure we can grab an image.
        if let posterPath = posterPath {
            let path = (rowImage) ? URLPath.getRowImage(posterPath).toString : URLPath.getDetailImage(posterPath).toString

            // Now send off the request.
            service.send(to: TMDBClient.Constants.imageHost, at: path) { success, json, data, error in
                // Make sure it was a success.
                var image: Data? = nil
                if success {
                    image = data
                } else {
                    if let error = error {
                        print("Error in grabbing image: \(error)")
                    }
                }

                // Finish the request by calling the closure.
                completion(image)
            }
        } else {
            completion(nil)
        }
    }
}

// MARK: - TMDBMovie: Equatable

extension TMDBMovie: Equatable {}

func ==(lhs: TMDBMovie, rhs: TMDBMovie) -> Bool {
    return lhs.id == rhs.id
}
