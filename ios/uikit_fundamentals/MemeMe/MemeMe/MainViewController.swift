//
//  MainViewController.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 12/12/16.
//  Copyright © 2016 Hibbard, Samuel. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //
    // IBOutlets to the MainViewController on Main.storyboard.
    //
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!

    //
    // ENUM for device permissions.
    //
    enum DevicePermission: Int {
        case camera
        case photoLibrary
    }

    typealias PermissionClosure = (Bool) -> Void // Used to tell the caller the permission.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
        Show the action items the user can do with the photo.
     */
    @IBAction func showActionItems(_ sender: AnyObject) {

    }

    /**
        Erase the text to start all over.
     */
    @IBAction func restartImage(_ sender: AnyObject) {

    }

    /**
        Show the camera to take a picture.
     */
    @IBAction func showCamera(_ sender: AnyObject) {
        // First check to make sure that camera is permitted.
        checkPermission(for: .camera) { (granted) in
            // See if the permission has been granted.
            if granted {
                // Now make sure that the camera is available.
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let camera = UIImagePickerController()
                    camera.delegate = self
                    camera.sourceType = .camera
                    camera.allowsEditing = false
                    self.present(camera, animated: true, completion: nil)
                }
            }
        }
    }

    /**
        Show the photo library to pick a picture.
     */
    @IBAction func showPhotoLibrary(_ sender: AnyObject) {
        // Check to see if photo library is available by the user.
        checkPermission(for: .photoLibrary) { (granted) in
            // Make sure it has been granted.
            if granted {
                // Now make sure that the photo library is available.
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let album = UIImagePickerController()
                    album.delegate = self
                    album.sourceType = .photoLibrary
                    album.allowsEditing = true
                    self.present(album, animated: true, completion: nil)
                }
            }
        }
    }

    /**
        User has picked the image.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Show the image on the screen now.
        imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage?

        // Finally dismiss the controller for camera or photo library.
        dismiss(animated: true, completion: nil)
    }

    /**
        Check permission for camera or photo library.

        @param service Which service that needs to be checked.
        @param closure Called after the permission has been found.
        @discussion This will check the permission and will show an alert if the permission has
                    been denied by the user.
     */
    func checkPermission(for service: DevicePermission, with closure: @escaping PermissionClosure) {
        // Create the closure. This will be called once the permission has been found.
        let PermissionFound: (Bool) -> Void = { granted in
            // Call the closure that was given from the parameter.
            DispatchQueue.main.async {
                closure(granted)
            }

            // Present an AlertViewController if it has not been granted.
            if !granted {
                DispatchQueue.main.async {
                    self.showAlert(for: service)
                }
            }
        }

        // Now request which permission we need.
        if service == .camera {
            requestCameraPermission(closure: PermissionFound)
        } else {
            requestPhotoLibraryPermission(closure: PermissionFound)
        }
    }

    /**
        Create the UIAlertController and show it to the user.

        @discussion This will have a cancel button and a settings button. The settings button will
                    take the user to the settings page for the app. So that the can give the app
                    permission.
     */
    func showAlert(for service: DevicePermission) {
        let messages = ["Camera access required for this feature.", "Photo Library access required for this feature"]

        // First create the UIAlertController.
        let alert = UIAlertController(title: "Permission Needed", message: messages[service.rawValue], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }

            // Now make sure it can be opened.
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Finally present the alert.
        present(alert, animated: true, completion: nil)
    }

    /**
        Check the permission for Photo Library. If first time asking show the default prompt.

        @param closure Will get called after the permission has been found.
     */
    func requestPhotoLibraryPermission(closure: @escaping PermissionClosure) {
        // Now determine the status for the photo library.
        switch(PHPhotoLibrary.authorizationStatus()) {
            case .authorized:
                closure(true)
                break
            case .restricted, .denied:
                closure(true)
                break
            default:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    var permitted = false
                    if status == .authorized {
                        permitted = true
                    }

                    closure(permitted)
                })
                break
        }
    }

    /**
        Check the permission for Camera. If first time asking show the default prompt.

        @param closure Will get called after the permission has been found.
     */
    func requestCameraPermission(closure: @escaping PermissionClosure) {
        // Determine the status for the camera.
        switch(AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)) {
            case .authorized:
                closure(true)
                break
            case .restricted, .denied:
                closure(false)
                break
            default:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted) in
                    closure(granted)
                }
                break
        }
    }
}

