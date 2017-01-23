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
enum ServiceRequestExtension {
    case requestToken
    case login
    case createSession
    case getAccount
    case setFavorite(String)

    var url: String {
        switch self {
            case .requestToken:
                return "/authentication/token/new"
            case .login:
                return "/authentication/token/validate_with_login"
            case .createSession:
                return "/authentication/session/new"
            case .getAccount:
                return "/account"
            case let .setFavorite(id):
                return "/account/\(id)/favorite"
        }
    }
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
    func sendRequest(to extensionPath: ServiceRequestExtension,
                     with urlParams: [String: AnyObject],
                     in method: String = "GET",
                     postData: [String: AnyObject]? = nil,
                     completion: @escaping (Bool, [String: AnyObject]?, String?) -> Void) {
        // First build the url with it's body.
        var request = URLRequest(url: buildURL(add: extensionPath, with: urlParams))

        // Set the header for the request.
        request.httpMethod = method

        // If this is a post then add to the header.
        if let postData = postData, method == "POST" {
            request.allHTTPHeaderFields = ["content-type": "application/json;charset=utf-8"]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: postData, options: .prettyPrinted)
            } catch {
                completion(false, nil, "Unable to convert postData into JSON. Here is the error:\n\(error)")
            }
        }

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
                    errorMessage = "Data could not be parsed as JSON. Here is the data returned:\n\(data)\nError:\(error)"
                }
            } else {
                if errorMessage == nil {
                    errorMessage = "No data returned from request."
                }
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
    private func buildURL(add extensionPath: ServiceRequestExtension, with urlParams: [String: AnyObject]) -> URL {
        // Start creating the url.
        var components = URLComponents()

        // Build the url.
        components.scheme = Constants.TMDB.ApiScheme
        components.host = Constants.TMDB.ApiHost
        components.path = Constants.TMDB.ApiPath + extensionPath.url

        // Now add the parameters for the body.
        if urlParams.count > 0 {
            components.queryItems = [URLQueryItem]()

            // Loop through the parameters and convert them to a URLQueryItem.
            for (key, value) in urlParams {
                let item = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(item)
            }
        }

        return components.url!
    }
}
