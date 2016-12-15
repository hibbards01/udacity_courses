//
//  ViewController.swift
//  ColorMaker
//
//  Created by Jason Schatz on 11/2/14.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redControl: UISlider!
    @IBOutlet weak var greenControl: UISlider!
    @IBOutlet weak var blueControl: UISlider!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set colorView on launch
        changeView()
    }

    func changeView() {
        let r = CGFloat(redControl.value)
        let g = CGFloat(greenControl.value)
        let b = CGFloat(blueControl.value)

        colorView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    // MARK: Actions

    @IBAction func changeColorComponent(_ sender: AnyObject) {
        // Make sure the program doesn't crash if the controls aren't connected
        if self.redControl == nil {
            return
        }

        changeView()
    }
}

