//
//  ClientService.swift
//  MyFavoriteMovies
//
//  Created by Hibbard, Samuel on 1/23/17.
//  Copyright (c) 2017 Udacity. All rights reserved.
//

import Foundation

/**
    Error codes for ClientService
 */
enum ClientError: LocalizedError {
    case dataToJsonFail(String)
    case requestError(String)
    case statusError(String)
    case jsonToDataFail(String)
    case weirdError(String)

    var errorDescription: String? {
        get {
            let desc: String
            switch self {
            case let .dataToJsonFail(errorDetails):
                desc = "Unable to convert data into JSON.\nError details:\n\(errorDetails)"
                break
            case let .requestError(errorDetails):
                desc = "Request returned an error:\n\(errorDetails)"
                break
            case let .statusError(errorDetails):
                desc = "Request status code did not succeed. Here is the status: \(errorDetails)"
                break
            case let .weirdError(errorDetails):
                desc = "Weird error occured. Here is the error:\n\(errorDetails)"
                break
            default:
                desc = ""
                break
            }

            return desc
        }

    }
}

/**
    Main class that will handle all the requests that are made to the server.
 */
class ClientService {
    /**
        Make the request to the service.

        @param host       The host we are trying to reach.
        @param path       The path on the host.
        @param method     What method the request will do. Defaults to GET.
        @param getData    The get params that need to be added to the url.
        @param postData   The data for the body of the request.
        @param returnJSON Return the data as type JSON, not Data. If set to false then the data
                          will not be parsed into JSON.
        @param completion The closure that will be called after everything has finished.
        @discussion The closure will return 4 parameters:
                        - Bool, if request was successful or not.
                        - [String, AnyObject]?, The data returned from the request in JSON.
                        - Data, Used the user specified that the data be returned
                                and not parsed into JSON.
                        - Error, If there is an error.
    */
    func send(to host: String,
               at path: String,
               by method: String = "GET",
               with getData: [String: AnyObject]? = nil,
               and postData: [String: AnyObject]? = nil,
               returnJSON: Bool = false,
               completion: @escaping (Bool, [String: AnyObject]?, Data?, Error?) -> Void) {
        // First build the URL that is needed.
        var request = URLRequest(url: buildURL(to: host, at: path, with: getData))

        // Set the headers for the request.
        request.httpMethod = method

        // Now do the conversion for POST.
        if let postData = postData, method == "POST" {
            do {
                request.allHTTPHeaderFields = ["content-type": "application/json;charset=utf-8"]
                request.httpBody = try JSONSerialization.data(withJSONObject: postData, options: .prettyPrinted)
            } catch {
                completion(false, nil, nil, ClientError.dataToJsonFail(error.localizedDescription))
            }
        }

        // Create a block that will grab the response from the request made.
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Make sure everything went well.
            var json: [String: AnyObject]?
            var clientError: ClientError?

            do {
                json = try self.checkForErrors(from: data, and: response, and: error, with: returnJSON)
            } catch let ce as ClientError {
                clientError = ce
            } catch {
                clientError = ClientError.weirdError(error.localizedDescription)
            }

            // If everything passed then make a bool a success.
            let success = clientError == nil ? true : false

            // Finally return the request to the client.
            completion(success, json, data, clientError)
        }

        // Start the request.
        task.resume()
    }

    /**
        Check the response to make sure there was no errors.

        @param data     The data returned.
        @param response The response that was given from the request.
        @param error    The error returned from the response, if any.
        @discussion This will return a JSON object if the request made knew there will be a JSON object returned.
                    Otherwise it doesn't do the conversion.
     */
    private func checkForErrors(from data: Data?, and response: URLResponse?, and error: Error?, with json: Bool) throws -> [String: AnyObject]? {
        // Start checking to make sure everything passed.
        var jsonData: [String: AnyObject]? = nil

        // First make sure that there was no error.
        if let error = error {
            throw ClientError.requestError(error.localizedDescription)
        }

        // Second, make sure the status was good.
        if let status = (response as? HTTPURLResponse)?.statusCode, status < 200 && status > 299 {
            throw ClientError.statusError("\(status)")
        }

        // If the data returned was JSON, make sure it can be converted to JSON.
        if let data = data, json {
            do {
                jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            } catch {
                throw ClientError.dataToJsonFail(error.localizedDescription)
            }
        }

        return jsonData
    }

    /**
        Build the url that will be needed in sending the request.

        @param
        @param path    The extension for the API call.
        @param getData The POST data that we need to send for the request.
     */
    private func buildURL(to host: String, at path: String, with getData: [String: AnyObject]?) -> URL {
        // Start creating the url.
        var components = URLComponents()

        // Build the url.
        components.scheme = "https" // Always set to be secure.
        components.host = host
        components.path = path

        // Now add the parameters for the body.
        if let data = getData, data.count > 0 {
            components.queryItems = [URLQueryItem]()

            // Loop through the parameters and convert them to a URLQueryItem.
            for (key, value) in data {
                let item = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(item)
            }
        }

        return components.url!
    }
}
