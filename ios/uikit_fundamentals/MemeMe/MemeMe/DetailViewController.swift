//
//  DetailView.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 1/16/17.
//  Copyright (c) 2017 Hibbard, Samuel. All rights reserved.
//

import Foundation
import UIKit

/**
    Show a detail view of the meme.
 */
class DetailViewController: UIViewController {
    //
    // IBOutlets
    //
    @IBOutlet weak var imageView: UIImageView!

    //
    // Member variables
    //
    var meme: Meme? = nil

    //
    // Overloaded functions
    //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the image.
        if let image = meme?.memeImage {
            self.imageView.image = image
        }
    }
}
