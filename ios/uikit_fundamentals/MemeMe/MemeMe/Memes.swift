//
//  Memes.swift
//  MemeMe
//
//  Created by Hibbard, Samuel on 12/29/16.
//  Copyright (c) 2016 Hibbard, Samuel. All rights reserved.
//

import Foundation
import UIKit

/**
    Keys for the Meme class when saved to UserDefaults.
 */
enum MemeKeys: String {
    case topTextKey = "topText"
    case bottomTextKey = "bottomText"
    case imageKey = "imageFilePath"
    case memeImageKey = "memeImageFilePath"
    case rootKey = "memes"
}

struct NotificationKeys {
    static let reloadListViewControllerKey = Notification.Name("ReloadListViewController")
    static let reloadGridViewControllerKey = Notification.Name("ReloadGridViewController")
}

/**
    Holds the data associated with a Meme.
 */
final class Meme: NSObject, NSCoding {
    //
    // Member variables
    //
    var topText: String
    var bottomText: String
    var image: UIImage
    var memeImage: UIImage

    //
    // Member Functions
    //

    /**
        Non-default constructor
     */
    init(top: String, bottom: String, imageFilePath: String, memeImageFilePath: String) {
        self.topText = top
        self.bottomText = bottom
        self.image = Meme.loadImage(from: imageFilePath)
        self.memeImage = Meme.loadImage(from: memeImageFilePath)
        self.image.filePath = imageFilePath
        self.memeImage.filePath = memeImageFilePath
    }

    /**
        Another non-default constructor
     */
    init(top: String, bottom: String, image: UIImage, memeImage: UIImage) {
        self.topText = top
        self.bottomText = bottom
        self.image = image
        self.memeImage = memeImage
    }

    /**
        Grab the data that was saved on UserDefaults
     */
    required convenience init(coder aDecoder: NSCoder) {
        // Grab the data
        let top = aDecoder.decodeObject(forKey: MemeKeys.topTextKey.rawValue) as! String
        let bottom = aDecoder.decodeObject(forKey: MemeKeys.bottomTextKey.rawValue) as! String

        // Grab the paths for where the image was saved.
        let imageFilePath = aDecoder.decodeObject(forKey: MemeKeys.imageKey.rawValue) as! String
        let memeImageFilePath = aDecoder.decodeObject(forKey: MemeKeys.memeImageKey.rawValue) as! String

        // Initialize the class.
        self.init(top: top, bottom: bottom, imageFilePath: imageFilePath, memeImageFilePath: memeImageFilePath)
    }

    /**
        Encode the class so that it can be saved to UserDefaults.
     */
    func encode(with coder: NSCoder) {
        // First save the images and get their file paths.
        image.filePath = Meme.save(for: image)
        memeImage.filePath = Meme.save(for: memeImage)

        // Encode the class
        coder.encode(topText, forKey: MemeKeys.topTextKey.rawValue)
        coder.encode(bottomText, forKey: MemeKeys.bottomTextKey.rawValue)
        coder.encode(image.filePath, forKey: MemeKeys.imageKey.rawValue)
        coder.encode(memeImage.filePath, forKey: MemeKeys.memeImageKey.rawValue)
    }

    /**
        Save the image to the user's folder.

        @param image The image we are saving.
        @discussion This will return the image path it was saved to for UserDefaults.
     */
    private class func save(for image: UIImage) -> String {
        // See if this image has already been saved to the UserDefaults
        // If it has then use the original path that it was saved to. If not then create a
        // brand new image file path.
        var imagePath = image.filePath
        if imagePath.isEmpty {
            imagePath = "image_\(Date.timeIntervalSinceReferenceDate).jpg"
        }

        // First grab the image data.
        let imageData = UIImageJPEGRepresentation(image, 1)

        // Now write the data to the path.
        do {
            let fullPath = Meme.fullDocumentsPath(append: imagePath)
            try imageData?.write(to: URL(fileURLWithPath: fullPath))
        } catch {
            print("ERROR: Could not save image. Here is error:\n\(error)")
        }

        return imagePath
    }

    /**
        Grab the image from the user's folder

        @param file The file path that the image was saved to.
     */
    private class func loadImage(from path: String) -> UIImage {
        // Grab the image from the path that was given.
        let fullPath = Meme.fullDocumentsPath(append: path)
        guard let image = UIImage(contentsOfFile: fullPath) else {
            return UIImage()
        }

        return image
    }

    /**
        Get the documents paths and append the image path.
     */
    private class func fullDocumentsPath(append imagePath: String) -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = "\((paths.last?.path)!)/\(imagePath)"
        return path
    }
}

// Adding another property for the file path the image is saved to.
private struct UIImageKeys {
    static var filePath = ""
}

extension UIImage {
    var filePath: String {
        get {
            guard let path = objc_getAssociatedObject(self, &UIImageKeys.filePath) as? String else {
                return ""
            }
            return path
        } set(value) {
            objc_setAssociatedObject(self, &UIImageKeys.filePath, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

/**
    Singleton class for where the MemeMes will be stored.
 */
class Memes {
    //
    // Member variables
    //
    static let sharedInstance = Memes() // This creates the singleton class.
    public private(set) var data = [Meme]()

    //
    // Member functions
    //

    /**
        Constructor
     */
    private init() {
        load()
    }

    /**
        Save the image to the array

        @param image       The initial image.
        @param topText     The text at the top of the MemeMe.
        @param bottomText  The text at the bottom of the MemeMe.
        @param memeImage   The Meme image.
     */
    func append(image: UIImage, topText: String, bottomText: String, memeImage: UIImage) {
        // Create a new MemeMe object and save it to the array.
        data.append(Meme(top: topText, bottom: bottomText, image: image, memeImage: memeImage))
    }

    /**
        Save the data to the phone.
     */
    func save() {
        if data.count > 0 {
            // Grab and use the UserDefaults.
            let userDefaults = UserDefaults.standard

            // Archive the data and set the key for the data.
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
            userDefaults.set(encodedData, forKey: MemeKeys.rootKey.rawValue)

            // Finally synchronize the data.
            userDefaults.synchronize()
        }
    }

    /**
        Load the data from the phone.
     */
    func load() {
        // Empty the data if needed.
        data.removeAll()

        // Grab the data from the UserDefaults and decode it.
        let memes = UserDefaults.standard.object(forKey: MemeKeys.rootKey.rawValue) as? Data

        // If there is nothing there then we have no data.
        if memes != nil {
            data = NSKeyedUnarchiver.unarchiveObject(with: memes!) as! [Meme]
        }
    }
}
