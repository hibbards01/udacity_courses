//
//  GridViewCell.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 1/3/17.
//  Copyright (c) 2017 Hibbard, Samuel. All rights reserved.
//

import Foundation
import UIKit

/**
    Main controller for each cell in the GridViewController.
 */
class GridViewCell: UICollectionViewCell {
    //
    // IBOutlets to GridViewController in Main.storyboard.
    //
    @IBOutlet weak var imageView: UIImageView!

    //
    // Override functions for UICollectionViewCell
    //

    /**
        Customize the cell.
     */
    override func layoutSubviews() {
        super.layoutSubviews()

        // Make the image to fit inside the view and to have the background black.
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
    }
}
