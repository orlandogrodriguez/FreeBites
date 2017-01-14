//
//  LoginViewController.swift
//  FreeBites
//
//  Created by Orlando G. Rodriguez on 12/25/16.
//  Copyright © 2016 Orlando G. Rodriguez. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // MARK: - UI Element Position Variables
    //Screen Variables
    var screen = UIView()
    var width:Double = 375
    var height:Double = 687
    var cWidth:Double = 375 / 2
    var cHeight:Double = 687 / 2
    var enabled:Bool = true
    var disabled:Bool = false

    
    //Eater Button Variables
    var eaterButton_xpos:Int = 0
    var eaterButton_ypos:Int = 0
    var eaterButton_width:Double = 0
    var eaterButton_height:Double = 0
    
    //Provider Button Variables
    var providerButton_xpos:Int = 0
    var providerButton_ypos:Int = 0
    var providerButton_width:Double = 0
    var providerButton_height:Double = 0
    
    //Eater/Provider Rounded Rectangle
    var eaterProviderIndicator_xpos:Int = 0
    var eaterProviderIndicator_ypos:Int = 0
    var eaterProviderIndicator_width:Double = 0
    var eaterProviderIndicator_height:Double = 0
    
    //SignInSignUpToggle Variables
    var signInSignUpToggle_xpos:Int = 0
    var signInSignUpToggle_ypos:Int = 0
    var signInSignUpToggle_width:Double = 0
    var signInSignUpToggle_height:Double = 0
    var signInSignUpToggle_alpha:Double = 0
    
    //Name Field Variables
    var nameField_xpos:Int = 0
    var nameField_ypos:Int = 0
    var nameField_width:Double = 0
    var nameField_height:Double = 0
    var nameField_alpha:Double = 0
    
    //Email Field Variables
    var emailField_xpos:Int = 0
    var emailField_ypos:Int = 0
    var emailField_width:Double = 0
    var emailField_height:Double = 0
    var emailField_alpha:Double = 0
    
    //Password Field Variables
    var passwordField_xpos:Int = 0
    var passwordField_ypos:Int = 0
    var passwordField_width:Double = 0
    var passwordField_height:Double = 0
    var passwordField_alpha:Double = 0
    
    //Proceed Button
    var proceedButton_xpos:Int = 0
    var proceedButton_ypos:Int = 0
    var proceedButton_width:Double = 0
    var proceedButton_height:Double = 0
    
    var locationManager: CLLocationManager!
    
    // MARK: - Database
    
    var ref = FIRDatabase.database().reference()
    
    // MARK: - Properties
    
    var globalMode = [0, 0]
    
    // MARK: - Actions
    
    @IBAction func eaterMode(_ sender: AnyObject) {
        setMode(0)
        handleUIPositions(phase: 0)
    
        //eaterModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Selected"), for: .normal)
        //eaterModeOutlet.layer.cornerRadius = eaterModeOutlet.frame.height / 2
        //providerModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Unselected"), for: .normal)
        
        //Update UI
        //updateEaterProviderSelectorPosition(newX: sender.frame.minX, newY: sender.frame.minY)
        
    }
   
    @IBAction func providerMode(_ sender: AnyObject) {
        setMode(1)
        signInSignUpToggleHelper()
        
        //providerModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Selected"), for: .normal)
        //eaterModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Unselected"), for: .normal)
        
        //Update UI
        //updateEaterProviderSelectorPosition(newX: sender.frame.minX, newY: sender.frame.minY)
        
    }
    
    @IBAction func proceedAction(_ sender: Any) {
        switch globalMode[0] {
        case 0:
            proceedAsEater()
        case 1:
            switch globalMode[1] {
            case 0:
                proceedAsProvider(0) //Proceed as provider signing in
            case 1:
                proceedAsProvider(1) //Proceed as provider signing up for the first time
            default:
                break;
            }
        default:
            break;
        }
    }
    
    @IBAction func signInSignUpToggle(_ sender: Any) {
        signInSignUpToggleHelper()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var eaterProviderSelector: UIImageView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var eaterModeOutlet: UIButton!
    @IBOutlet weak var providerModeOutlet: UIButton!
    @IBOutlet weak var proceedOutlet: UIButton!
    
    @IBOutlet weak var signInSignUpToggleOutlet: UISegmentedControl!
    
    // MARK: - Application //////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultLoginPageParameters()
        drawUIElements()
        handleUIPositions(phase: 0)
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        nameField.delegate = self
        
        nameField.tag = 0
        emailField.tag = 1
        passwordField.tag = 2
        

    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        try! FIRAuth.auth()?.signOut()
        
        // TODO: - Implement the below code as part of the main menu.
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user {
                print ("Welcome \(user.email!)!")
            } else {
                print ("You need to sign up or sign in first!")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
///////////////////////////////////////////////////////////////////
////// MARK: - Helper Functions ///////////////////////////////////
///////////////////////////////////////////////////////////////////
    
    /*
    // MARK: - Eater/Provider Toggle Helpers
    // These functions take care of the behavior and appearance of
    // the view controller when toggling between eater and provider
    // mode
    */
    func setMode(_ mode:Int) {
        globalMode[0] = mode
    }
    func setDefaultLoginPageParameters() {
        setMode(0)
    }
    func proceedAsEater() {
            performSegue(withIdentifier: "proceedSegue", sender: self)
    }
    func proceedAsProvider(_ mode:Int) -> () {
        switch mode {
        //Signing in existing user
        case 0:
            if checkValidCredentials(0) {
                signInHelper()
            }
        //Creating a new user
        case 1:
            if checkValidCredentials(1) {
                signUpHelper()
            }
        default:
            break;
        }
    }
    
    /*
    // MARK: - SignIn / SignUp Helpers
    // These functions take care of all the Firebase authentication
    // functionality for signing in and signing up. They also
    // manage the creation of new users in the database.
    */
    func signInSignUpToggleHelper() -> () {
        switch signInSignUpToggleOutlet.selectedSegmentIndex {
        case 0:
            print("Sign In Mode");
            globalMode[1] = 0
            handleUIPositions(phase: 1)
        case 1:
            print("Sign Up Mode");

            globalMode[1] = 1
            handleUIPositions(phase: 2)
        default:
            break;
        }
    }
    func signInHelper() -> () {
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if let error = error {
                print (error.localizedDescription)
                print("password incorrect")
                self.alertHelper(customTitle: "Whoops...", customMessage: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "proceedSegue", sender: self)
            }
        })
    }
    func signUpHelper() -> () {
        var newUserEmail:String = ""
        var newUserName:String = ""
        
        FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if let error = error {
                print (error.localizedDescription)
                self.alertHelper(customTitle: "Whoops...", customMessage: error.localizedDescription)
            } else {
                newUserEmail = user!.email!
                if self.nameIsValid() {
                    newUserName = self.nameField.text!
                }
                self.ref.child("users").child(user!.uid).setValue([
                    "email" : newUserEmail,
                    "name"  : newUserName])
                user!.sendEmailVerification()
                self.performSegue(withIdentifier: "proceedSegue", sender: self)
            }
        })
    }
    
    // MARK: - Credentials Validation
    func checkValidCredentials(_ mode:Int) -> Bool {
        switch mode {
        case 0:
            //Provider signing in, so we only check for email and password
            if emailIsValid() && passwordIsValid() {
                return true
            } else {
                self.alertHelper(customTitle: "Whoops...", customMessage: "Email/Password combination is invalid.")
            };
        case 1:
            //Provider creating a new acount, we check for the validity of everything
            if emailIsValid() && passwordIsValid() && nameIsValid() {
                return true
            } else {
                self.alertHelper(customTitle: "Whoops...", customMessage: "Make sure valid information is provided for all fields.")
            };
        default:
            break;
        }
        return false
    }
    func emailIsValid() -> Bool {
        //For now just check for empty string.
        //TODO: - Implement validity check for email
        if let txt = emailField.text {
            if txt == "" {
                return false
            }
            return true
        } else {
            return false
        }
    }
    func passwordIsValid() -> Bool {
        //For now just check for empty string.
        //TODO: - Implement validity check for password
        if let txt = passwordField.text {
            if txt == "" || txt.characters.count < 6 {
                return false
            }
            return true
        } else {
            return false
        }
    }
    func nameIsValid() -> Bool {
        //For now just check for empty string.
        //TODO: - Implement validity check for name
        if let txt = nameField.text {
            if txt == "" {
                return false
            }
            return true
        } else {
            return false
        }
    }
    func alertHelper(customTitle:String, customMessage:String) {
        let alert = UIAlertController(title: customTitle, message: customMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // TODO: - Implement this in a separate UI elements class.
    
    // MARK: - UI Helpers
    func drawUIElements() {
        //Draw lines at the bottom of the text fields
        let width = screen.frame.width
        let height = screen.frame.height
        let cWidth = width / 2
        let cHeight = height / 2
        drawLinesUnderTextFields()
        
        //Draw Eater/Provider Selector rounded rectangle
        //First set up the rounded rect for the first time and add corner radius.
        //updateEaterProviderSelectorPosition(newX: eaterModeOutlet.frame.minX, newY: eaterModeOutlet.frame.minY)
        eaterProviderSelector.layer.cornerRadius = eaterProviderSelector.frame.height * 0.5
        //SignInSignUpToggle
        signInSignUpToggleOutlet.layer.cornerRadius = signInSignUpToggleOutlet.frame.height * 0.5
        //signInSignUpToggleOutlet.isEnabled = false
        proceedOutlet.layer.cornerRadius = proceedOutlet.frame.height * 0.5
    }
    func drawLinesUnderTextFields() {
        let border1 = CALayer()
        let border2 = CALayer()
        let border3 = CALayer()
        
        let width = CGFloat(2.0)
        
        border1.borderColor = UIColor.white.cgColor
        border1.frame = CGRect(x: 0, y: nameField.frame.size.height - width, width:  nameField.frame.size.width, height: nameField.frame.size.height)
        border1.borderWidth = width
        
        border2.borderColor = UIColor.white.cgColor
        border2.frame = CGRect(x: 0, y: emailField.frame.size.height - width, width:  emailField.frame.size.width, height: emailField.frame.size.height)
        border2.borderWidth = width
        
        border3.borderColor = UIColor.white.cgColor
        border3.frame = CGRect(x: 0, y: passwordField.frame.size.height - width, width:  passwordField.frame.size.width, height: passwordField.frame.size.height)
        border3.borderWidth = width
        
        nameField.layer.addSublayer(border1)
        emailField.layer.addSublayer(border2)
        passwordField.layer.addSublayer(border3)
        
        nameField.layer.masksToBounds = true
        emailField.layer.masksToBounds = true
        passwordField.layer.masksToBounds = true
    }
    /*
    func updateEaterProviderSelectorPosition(newX: CGFloat, newY: CGFloat) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.eaterProviderSelector.layer.frame = CGRect(x: newX, y: newY, width: self.eaterModeOutlet.frame.width, height: self.eaterModeOutlet.frame.height)
        }, completion: nil)
    }
    */
    func disableAllFields() {
        nameField.isEnabled = false
        emailField.isEnabled = false
        passwordField.isEnabled = false
        signInSignUpToggleOutlet.isEnabled = false
    }
    func enableAllFields() {
        nameField.isEnabled = true
        emailField.isEnabled = true
        passwordField.isEnabled = true
        signInSignUpToggleOutlet.isEnabled = true
    }
    func handleUIPositions(phase: Int) {
        //Helpers
        let gap = 10.0
        let element = 44.0
        
        //Eater Button Default Values
        eaterButton_width = width * 0.4
        eaterButton_height = 44
        eaterButton_xpos = 40
        
        providerButton_width = eaterButton_width
        providerButton_height = 44
        providerButton_xpos = Int(width - 40 - eaterButton_width)
        
        eaterProviderIndicator_width = eaterButton_width
        eaterProviderIndicator_height = eaterButton_height
        
        signInSignUpToggle_xpos = 40
        signInSignUpToggle_height = 20
        signInSignUpToggle_width = width - 80
        signInSignUpToggle_height = 30
        signInSignUpToggle_alpha = 0
        
        nameField_xpos = 40
        nameField_width = width - 80
        nameField_height = 44
        
        emailField_xpos = 40
        emailField_width = width - 80
        emailField_height = 44
        
        passwordField_xpos = 40
        passwordField_width = width - 80
        passwordField_height = 44
        
        proceedButton_xpos = 40
        proceedButton_width = width - 80
        proceedButton_height = 44
        
        switch phase {
        case 0:
            eaterButton_ypos = Int(cHeight - gap - eaterButton_height)
            providerButton_ypos = eaterButton_ypos
            proceedButton_ypos = Int(cHeight + gap)
            eaterProviderIndicator_ypos = eaterButton_ypos
            eaterProviderIndicator_xpos = eaterButton_xpos
            signInSignUpToggle_ypos = Int(cHeight - (0.5 * element))
            nameField_ypos = Int(cHeight - (0.5 * element))
            emailField_ypos = Int(cHeight - (0.5 * element))
            passwordField_ypos = Int(cHeight - (0.5 * element))
            self.signInSignUpToggleOutlet.isEnabled = false
            self.nameField.isEnabled = false
            self.emailField.isEnabled = false
            self.passwordField.isEnabled = false
            self.signInSignUpToggleOutlet.isHidden = true
            self.nameField.isHidden = true
            self.emailField.isHidden = true
            self.passwordField.isHidden = true
            nameField_alpha = 0
            emailField_alpha = 0
            passwordField_alpha = 0
            signInSignUpToggle_alpha = 0
            print("phase \(phase)")
        case 1:
            eaterButton_ypos = Int(cHeight - (2.5 * element) - (2 * gap))
            providerButton_ypos = Int(cHeight - (2.5 * element) - (2 * gap))
            signInSignUpToggle_ypos = Int(cHeight - (1.5 * element))
            emailField_ypos = Int(cHeight - (0.5 * element))
            passwordField_ypos = Int(cHeight + (0.5 * element) + gap)
            proceedButton_ypos = Int(cHeight + (1.5 * element) + (3.0 * gap))
            eaterProviderIndicator_xpos = providerButton_xpos
            eaterProviderIndicator_ypos = providerButton_ypos
            nameField_alpha = 0
            emailField_alpha = 1
            passwordField_alpha = 1
            signInSignUpToggle_alpha = 1
            self.signInSignUpToggleOutlet.isEnabled = true
            self.nameField.isEnabled = false
            self.emailField.isEnabled = true
            self.passwordField.isEnabled = true
            self.signInSignUpToggleOutlet.isHidden = false
            self.nameField.isHidden = true
            self.emailField.isHidden = false
            self.passwordField.isHidden = false
            print("phase \(phase)")
        case 2:
            eaterButton_ypos = Int(cHeight - (3.0 * element) - (3.0 * gap))
            providerButton_ypos = Int(cHeight - (3.0 * element) - (3.0 * gap))
            signInSignUpToggle_ypos = Int(cHeight - (2.0 * element) - (1.5 * gap))
            nameField_ypos = Int(cHeight - (1.0 * element) - (1.5 * gap))
            emailField_ypos = Int(cHeight - (0.0 * element) - (0.5 * gap))
            passwordField_ypos = Int(cHeight + (1.0 * element) + (0.5 * gap))
            proceedButton_ypos = Int(cHeight + (2.0 * element) + (2.5 * gap))
            eaterProviderIndicator_xpos = providerButton_xpos
            eaterProviderIndicator_ypos = eaterButton_ypos
            nameField_alpha = 1
            emailField_alpha = 1
            passwordField_alpha = 1
            signInSignUpToggle_alpha = 1
            self.signInSignUpToggleOutlet.isEnabled = true
            self.nameField.isEnabled = true
            self.emailField.isEnabled = true
            self.passwordField.isEnabled = true
            self.signInSignUpToggleOutlet.isHidden = false
            self.nameField.isHidden = false
            self.emailField.isHidden = false
            self.passwordField.isHidden = false
            print("phase \(phase)")
        default:
            break;
        }
        updateUIPositions()
    }
    func updateUIPositions() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            //Update Eater/Provider Selector
            self.eaterProviderSelector.frame = CGRect(x: Double(self.eaterProviderIndicator_xpos), y: Double(self.eaterProviderIndicator_ypos), width: self.eaterProviderIndicator_width, height: self.eaterProviderIndicator_height)
            self.eaterModeOutlet.frame = CGRect(x: Double(self.eaterButton_xpos), y: Double(self.eaterButton_ypos), width: self.eaterButton_width, height: self.eaterButton_height)
            self.providerModeOutlet.frame = CGRect(x: Double(self.providerButton_xpos), y: Double(self.providerButton_ypos), width: self.providerButton_width, height: self.providerButton_height)
            self.signInSignUpToggleOutlet.frame = CGRect(x: Double(self.signInSignUpToggle_xpos), y: Double(self.signInSignUpToggle_ypos), width: self.signInSignUpToggle_width, height: self.signInSignUpToggle_height)
            self.nameField.frame = CGRect(x: Double(self.nameField_xpos), y: Double(self.nameField_ypos), width: self.nameField_width, height: self.nameField_height)
            self.emailField.frame = CGRect(x: Double(self.emailField_xpos), y: Double(self.emailField_ypos), width: self.emailField_width, height: self.emailField_height)
            self.passwordField.frame = CGRect(x: Double(self.passwordField_xpos), y: Double(self.passwordField_ypos), width: self.passwordField_width, height: self.passwordField_height)
            self.proceedOutlet.frame = CGRect(x: Double(self.proceedButton_xpos), y: Double(self.proceedButton_ypos), width: self.proceedButton_width, height: self.proceedButton_height)
            self.nameField.alpha = CGFloat(self.nameField_alpha)
            self.emailField.alpha = CGFloat(self.emailField_alpha)
            self.passwordField.alpha = CGFloat(self.passwordField_alpha)
            self.signInSignUpToggleOutlet.alpha = CGFloat(self.signInSignUpToggle_alpha)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    

}

/*
 // MARK: - Keyboard stuff
 */
//extension UIViewController {
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//    }
//    
//    func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}

