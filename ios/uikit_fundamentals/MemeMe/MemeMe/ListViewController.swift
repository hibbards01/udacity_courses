//
//  ListViewController.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 12/29/16.
//  Copyright (c) 2016 Hibbard, Samuel. All rights reserved.
//

import Foundation
import UIKit

/**
    Main controller for the table view of all the Memes.
 */
class ListViewController: UITableViewController {
    //
    // Member functions
    //

    /**
        Reload the data.
     */
    func reload() {
        tableView.reloadData()
    }

    /**
        Deconstructor.
     */
    deinit {
        // Remove the notification that was created.
        NotificationCenter.default.removeObserver(self, name: NotificationKeys.reloadListViewControllerKey, object: nil)
    }

    //
    // Override the UITableViewController functions
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove the line separtor in the table.
        tableView.separatorStyle = .none

        // Set the height for all the rows.
        tableView.rowHeight = 105

        // Create the notification for this controller.
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NotificationKeys.reloadListViewControllerKey, object: nil)
    }

    /**
        Show the picture that the user selected.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Initialize the DetailViewController and set the image.
        if let controller = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            controller.meme = Memes.sharedInstance.data[indexPath.row]

            // Now present it using the NavigationController.
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    /**
        Return the size of the memes array.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = Memes.sharedInstance.data.count

        // If there is no data then show a message saying the person has no Memes.
        if rows == 0 {
            // Create the label and set it to the background of the table view.
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            label.text = "Zero Memes created"
            label.textColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
            label.textAlignment = .center
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }

        return rows
    }

    /**
        Return what the cell should look like for a given row.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Grab the meme for the row.
        let meme = Memes.sharedInstance.data[indexPath.row]

        // Start creating the cell. Set the image and text to what is given.
        let cell = ListViewCell(style: .default, reuseIdentifier: "ListViewCellReuse")
        cell.imageView?.image = meme.memeImage
        cell.textLabel?.text = "\(meme.topText) . . . \(meme.bottomText)"

        return cell
    }
}
