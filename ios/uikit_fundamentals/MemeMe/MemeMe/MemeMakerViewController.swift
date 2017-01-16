//
//  MemeMakerViewController.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 12/12/16.
//  Copyright © 2016 Hibbard, Samuel. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

/**
    Main controller for creating a MemeMe.
 */
class MemeMakerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    //
    // IBOutlets to the MemeMakerViewController in Main.storyboard.
    //
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextView: UITextView!
    @IBOutlet weak var bottomTextView: UITextView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextViewWidthConstraint: NSLayoutConstraint!

    //
    // ENUM for device permissions.
    //
    enum DevicePermission: String {
        case camera = "Camera access required for this feature."
        case photoLibrary = "Photo Library access required for this feature"
    }

    //
    // Error codes if there is an error.
    //
    enum MainViewControllerError: String {
        case one = "You must pick an image in order to share."
        case two = "Unable to create MemeMe Image. Please try again."
    }

    typealias PermissionClosure = (Bool) -> Void // Used to tell the caller the permission.

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the maximum lines for the text fields and attributes
        topTextView.textContainer.maximumNumberOfLines = 2
        bottomTextView.textContainer.maximumNumberOfLines = 2

        // Setup the delegates.
        topTextView.delegate = self
        bottomTextView.delegate = self

        // Subscribe to the keyboard notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

        // Request to know when the device has changed orientation.
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        // Set the height of the image view.
        setImageHeight()

        // Look for taps made on the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(MemeMakerViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    /**
        Remove the observers after the uiviewcontroller is deallocated.
     */
    deinit {
        // Unsubscribe the keyboard notifications
        NotificationCenter.default.removeObserver(self)
    }

    /**
        Don's show the status bar in the controller.
     */
    override var prefersStatusBarHidden: Bool {
        return true
    }



// MARK: = IBAction functions.

    /**
        Show the action items the user can do with the photo.
     */
    @IBAction func showActionItems(_ sender: AnyObject) {
        // Make sure the image and one of the textfields is filled.
        if imageView.image != nil {
            if let image = createMemeImage() {
                // Now create the controller and show it to the user. Also create a completion handler to see
                // if we need to save the image or not.
                let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                activityVC.completionWithItemsHandler = {(activity, success, items, error) in
                    // If successful then save the meme and dismiss this controller.
                    if success {
                        Memes.sharedInstance.append(image: self.imageView.image!, topText: self.topTextView.text, bottomText: self.bottomTextView.text, memeImage: image)

                        // Notify the controllers to reload their data.
                        NotificationCenter.default.post(name: NotificationKeys.reloadListViewControllerKey, object: nil)
                        NotificationCenter.default.post(name: NotificationKeys.reloadGridViewControllerKey, object: nil)

                        // Dismiss this controller.
                        DispatchQueue.main.async {
                            self.dismiss(animated: true)
                        }
                    }
                }

                // Finally present the controller.
                present(activityVC, animated: true, completion: nil)
            }
        } else {
            showError(with: .one)
        }
    }

    /**
        Dismiss the view controller.
     */
    @IBAction func dismissModal(_ sender: AnyObject) {
        NotificationCenter.default.post(name: NotificationKeys.reloadListViewControllerKey, object: nil, userInfo: ["reloadData": false])
        dismiss(animated: true)
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
                    album.allowsEditing = false
                    self.present(album, animated: true, completion: nil)
                }
            }
        }
    }

// MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate functions.

    /**
        User has picked the image.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Finally dismiss the controller for camera or photo library.
        dismiss(animated: true, completion: nil)

        // Show the image on the screen now.
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image

            // Now move the text fields to be within the picture.
            adjustTextFields()
        }
    }

// MARK: - UITextViewDelegate functions.

    /**
        Make all the text selected. So that the user can just start typing.
     */
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Erase the text field if this is the first time.
        if textView.text == "TOP" || textView.text == "BOTTOM" {
            textView.text = ""
        }
    }

    /**
        Dismiss the keyboard if the return key is clicked upon.
     */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }

        return true
    }

// MARK: - Other functions needed for controller.

    /**
        Create the Mememe image.
     */
    func createMemeImage() -> UIImage? {
        // Grab the image, text, and their corresponding CGRects' and attributes.
        // First the image.
        let orgImage = imageView.image!
        let imageRect = CGRect(x: 0, y: 0, width: orgImage.size.width, height: orgImage.size
                .height)

        // First we need to determine how much the image was changed from what the user sees.
        let imageFrame = getAspectRatioOfImage()

        // Find the ratio change given from the imageFrame and the originalImage
        let ratio = orgImage.size.height / imageFrame.size.height

        // Now the text
        let topText: NSString = NSString(string: topTextView.text)
        let bottomText: NSString = NSString(string: bottomTextView.text)
        var topRect = topTextView.frame
        var bottomRect = bottomTextView.frame

        // Change the text's height to be what the user sees. May need to be bigger or smaller.
        topRect.size.height = topRect.size.height * ratio
        bottomRect.size.height = bottomRect.size.height * ratio

        // and it's attributes.
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        // Change the font size to reflect the image size.
        let font = topTextView.font!.withSize(40.0 * ratio)

        // Finally save the attributes.
        let textAttributes = [NSFontAttributeName: font,
                              NSForegroundColorAttributeName: topTextView.textColor!,
                              NSParagraphStyleAttributeName: style] as [String : Any]

        // Make the x zero for both topRect and bottomRect. So that it aligns itself to the image.
        topRect.origin.x = 0
        bottomRect.origin.x = 0

        // Adjust the y for the texts to be aligned at the top and bottom of the picture.
        topRect.origin.y = 8
        bottomRect.origin.y = imageRect.size.height - bottomRect.size.height

        // Also make the width the same as the image.
        topRect.size.width = imageRect.size.width
        bottomRect.size.width = imageRect.size.width

        // Start creating the image!
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageRect.size.width, height: imageRect.size.height), true, 0)

        // Now draw the image to the graphics context.
        orgImage.draw(in: imageRect)

        // Now draw the text.
        topText.draw(in: topRect, withAttributes: textAttributes)
        bottomText.draw(in: bottomRect, withAttributes: textAttributes)

        // Grab the new image that was created.
        let image = UIGraphicsGetImageFromCurrentImageContext()

        // End the process.
        UIGraphicsEndImageContext()

        return image
    }

    /**
        Called when the orientation of the device has been changed.
     */
    func orientationChanged(_ notification: Notification) {
        setImageHeight()
        adjustTextFields()
    }

    /**
        Dismiss the keyboard when the user taps outside the text view.
     */
    func dismissKeyboard() {
        view.endEditing(true)
    }

// MARK: - Observer function for when the keyboard will appear.

    /**
        Move the view to accommodate for the keyboard on the bottom text field.
     */
    func keyboardWillShow(_ notification: Notification) {
        // First check to see which text field has been selected.
        if bottomTextView.isFirstResponder {
            // If it is the bottom one then we need to move the scroll view.
            // Grab the frame of the keyboard.
            let keyboardFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size

            // Now add the height of that to the scroll view so that it will be moved.
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset

            // Move the scroll view to show the text field.
            var viewFrame = view.frame
            viewFrame.size.height -= keyboardFrame.height
            scrollView.scrollRectToVisible(bottomTextView.frame, animated: true)
        }
    }

    /**
        Move the view back to the original position once the keyboard disappears.
     */
    func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }

// MARK: - Private functions for class.

    /**
        Grab the image frame that was changed within the imageView.
     */
    private func getAspectRatioOfImage() -> CGRect {
        // Grab the original image view frame and adjust the height.
        let imageViewFrame = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: view.frame.width, height: imageViewHeight.constant)

        // Return the frame from the image that was changed within the imageView.
        return AVMakeRect(aspectRatio: imageView.image!.size, insideRect: imageViewFrame)
    }

    /**
        Set the image height based off the height of the screen.
     */
    private func setImageHeight() {
        imageViewHeight.constant = view.frame.size.height - 88
    }

    /**
        Adjusts the text fields to their correct position.
     */
    private func adjustTextFields() {
        // If there is no image then set the constants to 8 by default.
        var constant: CGFloat = 8.0
        var width: CGFloat = 375
        if imageView.image != nil {
            let imageFrame = getAspectRatioOfImage()

            // Now see if the image's height is the same as the imageView.
            if imageViewHeight.constant == imageFrame.height {
                // Since they are adjust the constraint for the text fields to be zero.
                constant = 0
            } else {
                // Otherwise adjust the text fields until they are within the picture.
                // Grab the total gap that the picture doesn't fill.
                // Half that for the two gaps to grab the constant needed for the constraints.
                constant = (imageViewHeight.constant - imageFrame.height) / 2
            }

            width = imageFrame.width
        }

        // Now adjust the gaps according to the constant
        topTextViewConstraint.constant = constant
        bottomTextViewConstraint.constant = constant

        // Make the width the same as the image.
        topTextViewWidthConstraint.constant = width
        bottomTextViewWidthConstraint.constant = width
    }

    /**
        Check permission for camera or photo library.

        @param service Which service that needs to be checked.
        @param closure Called after the permission has been found.
        @discussion This will check the permission and will show an alert if the permission has
                    been denied by the user.
    */
    private func checkPermission(for service: DevicePermission, with closure: @escaping PermissionClosure) {
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
    private func showAlert(for service: DevicePermission) {
        // First create the UIAlertController.
        let alert = UIAlertController(title: "Permission Needed", message: service.rawValue, preferredStyle: .alert)
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
        Show the error that was made.

        @param error The enum error code.
     */
    private func showError(with error: MainViewControllerError) {
        // Now create the UIAlertConroller.
        let alert = UIAlertController(title: error.rawValue, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        // Now present it to the user.
        present(alert, animated: true, completion: nil)
    }

    /**
        Check the permission for Photo Library. If first time asking show the default prompt.

        @param closure Will get called after the permission has been found.
     */
    private func requestPhotoLibraryPermission(closure: @escaping PermissionClosure) {
        // Now determine the status for the photo library.
        switch(PHPhotoLibrary.authorizationStatus()) {
            case .authorized:
                closure(true)
                break
            case .restricted, .denied:
                closure(false)
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
    private func requestCameraPermission(closure: @escaping PermissionClosure) {
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

