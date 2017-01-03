//
//  ListViewCell.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 12/30/16.
//  Copyright (c) 2016 Hibbard, Samuel. All rights reserved.
//

import Foundation
import UIKit

/**
    Define the cells for the ListViewController
 */
class ListViewCell: UITableViewCell {
    //
    // Override the UITableViewCell functions
    //

    /**
        Change the size of image and text.
     */
    override func layoutSubviews() {
        super.layoutSubviews()

        // First make the image and text bigger.
        imageView?.frame = CGRect(x: 0, y: 0, width: 160, height: frame.height)
        imageView?.contentMode = .scaleAspectFit

        // Customize the text as well
        textLabel?.frame = CGRect(x: 170, y: 0, width: frame.width - 170, height: frame.height)
    }
}
