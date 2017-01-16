//
//  GridViewController.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 12/29/16.
//  Copyright (c) 2016 Hibbard, Samuel. All rights reserved.
//

import Foundation
import UIKit

/**
    Main Controller for the collection view of the Memes.
 */
class GridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //
    // Member functions
    //

    /**
        Reload the data.
     */
    func reload() {
        collectionView?.reloadData()
    }

    /**
        Deconstructor.
     */
    deinit {
        NotificationCenter.default.removeObserver(self, name: NotificationKeys.reloadGridViewControllerKey, object: nil)
    }

    //
    // Override the UICollectionViewController functions.
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the notification for this controller.
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NotificationKeys.reloadGridViewControllerKey, object: nil)
    }

    /**
        Show the Meme in the DetialController.
     */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Initialize the DetailViewController and set the image.
        if let controller = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            controller.meme = Memes.sharedInstance.data[indexPath.row]

            // Now present it using the NavigationController.
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    /**
        Return the number of memes.
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = Memes.sharedInstance.data.count

        // If there is no data then show a message saying the person has no Memes.
        if items == 0 {
            // Create the label and set it to the background of the table view.
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            label.text = "Zero Memes created"
            label.textColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
            label.textAlignment = .center
            collectionView.backgroundView = label
        } else {
            collectionView.backgroundView = nil
        }

        return items
    }

    /**
        Return the custom cell with just the meme picture.
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Grab the meme.
        let meme = Memes.sharedInstance.data[indexPath.row]

        // Create the cell and add the picture from the meme.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCellReuse", for: indexPath) as! GridViewCell
        cell.imageView.image = meme.memeImage

        return cell
    }

    /**
        Divides collectionView to have 3 columns.
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (collectionView.frame.width / 3) - 7

        return CGSize(width: cellSize, height: cellSize)
    }
}
