//
//  TMDBAuthViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - TMDBAuthViewController: UIViewController

class TMDBAuthViewController: UIViewController {

    // MARK: Properties
    
    var urlRequest: URLRequest? = nil
    var requestToken: String? = nil
    var completionHandlerForView: ((_ success: Bool, _ errorString: String?) -> Void)? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        navigationItem.title = "TheMovieDB Auth"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAuth))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let urlRequest = urlRequest {
            webView.loadRequest(urlRequest)
        }
    }
    
    // MARK: Cancel Auth Flow
    
    func cancelAuth() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TMDBAuthViewController: UIWebViewDelegate

extension TMDBAuthViewController: UIWebViewDelegate {
    /**
        Check the url to see if the user has given consent.
     */
    func webViewDidFinishLoad(_ webView: UIWebView) {
        var allowed: Bool? = nil
        if let url = webView.request?.url?.absoluteString, let requestToken = requestToken {
            if url == "\(TMDBClient.Constants.AuthorizationURL)\(requestToken)/allow" {
                allowed = true
            } else if url == "\(TMDBClient.Constants.AuthorizationURL)\(requestToken)/deny" {
                allowed = false
            }

            // See if we need to dismiss the controller.
            if let allowed = allowed, let completionHandlerForView = completionHandlerForView {
                dismiss(animated: true) {
                    let error = (allowed) ? "" : "User denied access to this app."

                    completionHandlerForView(allowed, error)
                }
            }
        }
    }
}
