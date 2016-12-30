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
    // Memeber functions
    //

    /**
        Reload the data.
     */
    func reload(_ notification: NSNotification) {
        // Remove the notification that was created.
        NotificationCenter.default.removeObserver(self, name: NotificationKeys.memeMakerDismissedKey, object: nil)

        // Grab the userinfo data to see if the table needs to be reloaded.
        if (notification.userInfo?["reloadData"] as? Bool)! {
            tableView.reloadData()
        }
    }

    //
    // Override the UITableViewController functions
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove the line separtor in the table.
        tableView.separatorStyle = .none
    }

    /**
        Show the picture that the user selected.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeReuseCell")!
        cell.textLabel?.text = "\(meme.topText) \(meme.bottomText)"
        cell.imageView?.image = meme.memeImage

        return cell
    }

    /**
        Prepare a notification to get notified if this controller needs to reload the data.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "MemeMakerViewController" {
            // Create the notification for this controller.
            NotificationCenter.default.addObserver(self, selector: #selector(reload(_:)), name: NotificationKeys.memeMakerDismissedKey, object: nil)
        }
    }
}
