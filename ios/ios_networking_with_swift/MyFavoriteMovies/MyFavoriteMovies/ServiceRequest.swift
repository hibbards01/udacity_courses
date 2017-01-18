//
//  ServiceRequest.swift
//  MyFavoriteMovies
//
//  Created by Hibbard, Samuel on 1/17/17.
//  Copyright (c) 2017 Udacity. All rights reserved.
//

import Foundation

/**
    Enum extension types. This will be used for the request in ServiceRequest.
 */
enum ServiceRequestExtension: String {
    case requestToken = "/authentication/token/new"
    case login = "/authentication/token/validate_with_login"
    case createSession = "/authentication/session/new"
    case getAccount = "/account"
}

/**
    Main class that will handle all the requests that are made to the server.
 */
class ServiceRequest {
    //
    // Member functions
    //

    /**
        Make request with parameters to the extension given.

        @param extension The extension for the API call.
        @param params    The POST data that we need to send for the request.
        @discussion      This will make the request and return true for a successful request.
                         False otherwise.
     */
    func sendRequest(to extensionPath: ServiceRequestExtension, with params: [String: AnyObject], completion: @escaping (Bool, [String: AnyObject]?, String?) -> Void) {
        // First build the url with it's body.
        let request = URLRequest(url: buildURL(add: extensionPath, with: params))

        // Now make the request.
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var errorMessage: String? = nil

            // Start checking to make sure everything passed.
            // First make sure that there was no error.
            if error != nil {
                errorMessage = "Error in the request. Here is the error:\n\(error!)"
            }

            // Make sure the status was good.
            if let status = (response as? HTTPURLResponse)?.statusCode,
                  status < 200 && status > 299 && errorMessage == nil {
                errorMessage = "Error in the request. Status code returned \(status)"
            }

            // See if there was any data returned. If so convert it to JSON.
            var jsonData:[String: AnyObject]? = nil
            if let data = data, errorMessage == nil {
                // Parse the data. Catch the error if it is not possible to do.
                do {
                    jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
                } catch {
                    errorMessage = "Data could not be parsed as JSON. Here is the data returned:\n\(data)"
                }
            } else {
                if errorMessage == nil {
                    errorMessage = "No data returned from request. Here is the data returned:\n\(data)"
                }
            }

            // Make sure that TheMoviewDB did not return an error.
            if let status = jsonData?[Constants.TMDBResponseKeys.StatusCode] as? Int, let message = jsonData?[Constants.TMDBResponseKeys.StatusMessage] {
                errorMessage = "Error with TheMovieDB api. Here is the status code: \(status) with message:\n\(message)"
            }

            // See if the request a success or not.
            var success = errorMessage == nil ? true : false
            if let good = jsonData?[Constants.TMDBResponseKeys.Success] as? Bool, success {
                success = good

                // Remove the success key from the json object.
                _ = jsonData?.removeValue(forKey: Constants.TMDBResponseKeys.Success)
            }

            // Finally return what happened in the request.
            completion(success, jsonData, errorMessage)
        }

        // Finally send off the request.
        task.resume()
    }

    //
    // Private member functions
    //

    /**
        Build the url that will be needed in sending the request.

        @param extension The extension for the API call.
        @param params    The POST data that we need to send for the request.
     */
    private func buildURL(add extensionPath: ServiceRequestExtension? = nil, with params: [String: AnyObject]) -> URL {
        // Start creating the url.
        var components = URLComponents()

        // Build the url.
        components.scheme = Constants.TMDB.ApiScheme
        components.host = Constants.TMDB.ApiHost
        components.path = Constants.TMDB.ApiPath + (extensionPath?.rawValue ?? "")

        // Now add the parameters for the body.
        if params.count > 0 {
            components.queryItems = [URLQueryItem]()

            // Loop through the parameters and convert them to a URLQueryItem.
            for (key, value) in params {
                let item = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(item)
            }
        }

        return components.url!
    }
}
