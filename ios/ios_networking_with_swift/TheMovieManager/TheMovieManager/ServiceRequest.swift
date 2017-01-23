//
//  ServiceRequest.swift
//  MyFavoriteMovies
//
//  Created by Hibbard, Samuel on 1/23/17.
//  Copyright (c) 2017 Udacity. All rights reserved.
//

import Foundation

/**
    Enum for base url. This is used for the ServiceRequestExntension enum.
 */
enum BaseURL: String {
    case apiHost = "api.themoviedb.org"
    case imageHost = "image.tmdb.org"
}

/**
    Enum service extension types. This will be used for the request in ServiceRequest.
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
            return "/3/authentication/token/new"
        case .login:
            return "/3/authentication/token/validate_with_login"
        case .createSession:
            return "/3/authentication/session/new"
        case .getAccount:
            return "/3/account"
        case let .setFavorite(id):
            return "/3/account/\(id)/favorite"
        }
    }
}