//
//  MemeMes.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 12/29/16.
//  Copyright (c) 2016 Hibbard, Samuel. All rights reserved.
//

import Foundation
import UIKit

/**
    Holds the data associated with a MemeMe
 */
struct MemeMe {
    var topText: String
    var bottomText: String
    var image: UIImage
    var imageWithText: UIImage
}

/**
    Singleton class for where the MemeMes will be stored.
 */
class MemeMes {
    //
    // Member variables
    //
    static let sharedInstance = MemeMes() // This creates the singleton class.
    public private(set) var data = [MemeMe]()

    //
    // Member functions
    //

    /**
        Save the image to the array

        @param image       The initial image.
        @param topText     The text at the top of the MemeMe.
        @param bottomText  The text at the bottom of the MemeMe.
        @param memeMeImage The MemeMe image.
     */
    func save(image: UIImage, topText: String, bottomText: String, memeMeImage: UIImage) {
        // Create a new MemeMe object and save it to the array.
        data.append(MemeMe(topText: topText, bottomText: bottomText, image: image, imageWithText: memeMeImage))
    }
}