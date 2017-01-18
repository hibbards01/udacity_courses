//
//  LoginViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {

    // MARK: Properties

    var appDelegate: AppDelegate!
    var keyboardOnScreen = false

    // MARK: Outlets

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate

        configureUI()

        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    // MARK: Login

    @IBAction func loginPressed(_ sender: AnyObject) {

        userDidTapView(self)

        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)

            /*
                Steps for Authentication...
                https://www.themoviedb.org/documentation/api/sessions

                Step 1: Create a request token
                Step 2: Ask the user for permission via the API ("login")
                Step 3: Create a session ID

                Extra Steps...
                Step 4: Get the user id ;)
                Step 5: Go to the next view!
            */
            getRequestToken()
        }
    }

    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MoviesTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }

    // MARK: TheMovieDB

    private func getRequestToken() {
        /* TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token */
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey as AnyObject
        ]

        // Make the request!
        appDelegate.service.sendRequest(to: .requestToken, with: methodParameters) { success, data, errorMessage in
            if success {
                // Grab the data because it was a success!
                // Make sure there is a requestToken given. If not print the error.
                guard let token = data?[Constants.TMDBResponseKeys.RequestToken] as? String else {
                    self.showError(with: "Login failed. (Request token)", and: "Error: No token given. Here is the data returned from request:\n\(data)")
                    return
                }

                // Now login the user!
                self.appDelegate.requestToken = token
                self.loginWithToken(self.appDelegate.requestToken!)
            } else {
                if let errorMessage = errorMessage {
                    self.showError(with: "Login failed. (Request token)", and: errorMessage)
                }
            }
        }
    }

    private func loginWithToken(_ requestToken: String) {
        /* TASK: Login, then get a session id */
        /* 1. Set the parameters */
        let params = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey as AnyObject,
            Constants.TMDBParameterKeys.Username: usernameTextField.text as AnyObject,
            Constants.TMDBParameterKeys.Password: passwordTextField.text as AnyObject,
            Constants.TMDBParameterKeys.RequestToken: requestToken as AnyObject
        ]

        // Make the request.
        appDelegate.service.sendRequest(to: .login, with: params) { success, data, error in
            // Make sure it was a success! If it was we can then grab the session id.
            // Else show an error.
            guard success else {
                self.showError(with: "Login failed with request token.", and: "Error message:\n\(error!)")
                return
            }

            self.getSessionID(requestToken)
        }
    }

    private func getSessionID(_ requestToken: String) {
        /* TASK: Get a session ID, then store it (appDelegate.sessionID) and get the user's id */
        /* 1. Set the parameters */
        let params = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey as AnyObject,
            Constants.TMDBParameterKeys.RequestToken: requestToken as AnyObject
        ]

        // Now make the request.
        appDelegate.service.sendRequest(to: .createSession, with: params) { success, data, error in
            guard success else {
                self.showError(with: "Login failed. (Session ID)", and: "Error message:\n\(error!)")
                return
            }

            // Make sure a session id is returned.
            guard let sessionID = data?[Constants.TMDBResponseKeys.SessionID] as? String else {
                self.showError(with: "Login failed. (Session ID)", and: "No session key. Here is the data:\n\(data)")
                return
            }

            // Now get the user id.
            self.appDelegate.sessionID = sessionID
            self.getUserID(sessionID)
        }
    }

    private func getUserID(_ sessionID: String) {
        /* TASK: Get the user's ID, then store it (appDelegate.userID) for future use and go to next view! */
        /* 1. Set the parameters */
        let params = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey as AnyObject,
            Constants.TMDBParameterKeys.SessionID: sessionID as AnyObject
        ]

        // Make the request.
        appDelegate.service.sendRequest(to: .getAccount, with: params) { success, data, error in
            guard success else {
                self.showError(with: "Login failed. (Account)", and: "Error message:\n\(error!)")
                return
            }

            // Grab the user id.
            guard let userID = data?[Constants.TMDBResponseKeys.UserID] as? Int else {
                self.showError(with: "Login failed. (Account)", and: "Unable to find user id. Here is the data:\n\(data)")
                return
            }

            // Save the user id and complete the login page.
            self.appDelegate.userID = userID
            self.completeLogin()
        }
    }

    /**
        Show error if there is one.

        @param label   The error to display on the UI.
        @param message The actual error that happened. Display in the console.
     */
    private func showError(with label: String, and message: String) {
        print(message)

        // Make sure to dispatch it to the main thread.
        DispatchQueue.main.async {
            self.setUIEnabled(true)
            self.debugTextLabel.text = label
        }
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Show/Hide Keyboard

    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            movieImageView.isHidden = true
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            movieImageView.isHidden = false
        }
    }

    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }

    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }

    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }

    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {

    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled

        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }

    func configureUI() {

        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)

        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }

    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {

    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }

    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
