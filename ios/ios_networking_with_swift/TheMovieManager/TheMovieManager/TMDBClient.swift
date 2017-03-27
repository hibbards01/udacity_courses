//RowPoster
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import Foundation

/**
    Enum service extension types. This will be used for the request in ServiceRequest.
 */
enum URLPath {
    case requestToken
    case login
    case createSession
    case getAccount
    case getFavorite(Int)
    case getRowImage(String)
    case getDetailImage(String)

    var toString: String {
        switch self {
            case .requestToken:
                return "/3/authentication/token/new"
            case .login:
                return "/3/authentication/token/validate_with_login"
            case .createSession:
                return "/3/authentication/session/new"
            case .getAccount:
                return "/3/account"
            case let .getFavorite(id):
                return "/3/account/\(id)/favorite/movies"
            case let .getRowImage(path):
                return "/t/p/\(TMDBClient.PosterSizes.RowPoster)\(path)"
            case let .getDetailImage(path):
                return "/t/p/\(TMDBClient.PosterSizes.DetailPoster)\(path)"
        }
    }
}

/**
    TMDBClient talks to the TMDB server. This will grab the necessary data that is needed.
 */
class TMDBClient {
    //
    // Member variables
    //
    static let sharedInstance = TMDBClient() // This makes the class a singleton.
    var images = TMDBConfig()                // Where the images are saved at.
    let service = ClientService()            // This makes the requests to the server.
    var movies = [TMDBMovie]()               // The favorite movies.
    var requestToken: String? = nil  // The request token that we save.
    var sessionID: String? = nil     // User is logged in.
    var userID: Int? = nil           // User ID from MovieDB.

    //
    // MARK - public methods
    //

    /**
        Grab the session and user id.

        @discussion This will complete the process in getting the session id, and
                    then finally grabbing the user id for other service requests.
                    This is invoked once the user has logged in.
     */
    func completeLogin(completion: @escaping (_ success: Bool) -> Void) {
        // Get the session id.
        getSessionID() {
            // Now the user id.
            self.getUserID() {
                // Make sure everything was a success.
                let success = (self.sessionID == nil || self.userID == nil) ? false : true

                // Tell the controller that we were successful!
                completion(success)
            }
        }

    }

    /**
        Get the request token from TMDB
     */
    func getRequestToken(completion: @escaping (_ token: String?) -> Void) {
        // Set the parameters.
        let methodParameters = [
            ParameterKeys.ApiKey: Constants.ApiKey as AnyObject
        ]

        // Now make the request.
        service.send(to: Constants.ApiHost, at: URLPath.requestToken.toString, with: methodParameters, returnJSON: true) { success, json, data, error in
            // See if it was a sucess.
            if success {
                // Grab the data because it was a success!
                // Make sure there is a requestToken given. If not print the error.
                if let token = json?[JSONResponseKeys.RequestToken] as? String {
                    self.requestToken = token
                } else {
                    print("Login failed. (Request token) Error: No token given. Here is the data returned from request:\n\(json)")
                    self.requestToken = nil
                }
            } else {
                if let error = error {
                    print("Request token failed: \(error.localizedDescription)")
                }
            }

            completion(self.requestToken)
        }
    }

    //
    // MARK - private methods
    //

    /**
        Get the session id for this user.
     */
    private func getSessionID(completion: @escaping () -> Void) {
        // Make sure we have a request token.
        if let requestToken = requestToken, sessionID == nil {
            // Setup the parameters for this request.
            let params = [
                ParameterKeys.ApiKey: Constants.ApiKey as AnyObject,
                ParameterKeys.RequestToken: requestToken as AnyObject
            ]

            // Now send off the request.
            service.send(to: Constants.ApiHost, at: URLPath.createSession.toString, with: params, returnJSON: true) { success, json, data, error in
                // See if it was a success.
                if success {
                    // Grab the session id.
                    if let id = json?[JSONResponseKeys.SessionID] as? String {
                        self.sessionID = id
                    } else {
                        print("Session ID not a part of the response: \(json)")
                        self.sessionID = nil
                    }

                } else {
                    if let error = error {
                        print("Get session ID failed: \(error.localizedDescription)")
                    }
                }

                // Call the completion handler.
                completion()
            }
        }
    }

    /**
        Get the user id.
     */
    private func getUserID(completion: @escaping () -> Void) {
        // See if we need to make a request for the user id.
        // Also make sure that we have a sessionID in order to make the request.
        if let sessionID = sessionID, userID == nil {
            // Create the parameters
            let params = [
                ParameterKeys.ApiKey: Constants.ApiKey as AnyObject,
                ParameterKeys.SessionID: sessionID as AnyObject
            ]

            // Send off the request.
            service.send(to: Constants.ApiHost, at: URLPath.getAccount.toString, with: params, returnJSON: true) { success, json, data, error in
                if success {
                    // Grab the user id.
                    if let id = json?[JSONResponseKeys.UserID] as? Int {
                        self.userID = id
                    } else {
                        print("User ID not provided from response: \(json)")
                        self.userID = nil
                    }
                } else {
                    if let error = error {
                        print("Getting user id failed: \(error.localizedDescription)")
                    }

                }

                // Call the completion handler.
                completion()
            }
        }
    }
}
