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

class LoginViewController: UIViewController {
    
    
    
    // MARK: - Database
    
    var ref = FIRDatabase.database().reference()
    
    // MARK: - Properties
    
    var globalMode = [0, 0]
    
    // MARK: - Actions
    
    @IBAction func eaterMode(_ sender: AnyObject) {
        setMode(0)
        
        eaterModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Selected"), for: .normal)
        providerModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Unselected"), for: .normal)
    }
   
    @IBAction func providerMode(_ sender: AnyObject) {
        setMode(1)
        signInSignUpToggleHelper()
        
        providerModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Selected"), for: .normal)
        eaterModeOutlet.setBackgroundImage(#imageLiteral(resourceName: "EaterProviderButton_Unselected"), for: .normal)
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
    
    // MARK: - Helper Functions
    
    //Eater/Provider Toggle
    func setMode(_ mode:Int) -> () {
        _ = mode == 1 ? enableAllFields() : disableAllFields()
        nameField.alpha = CGFloat(mode)
        emailField.alpha = CGFloat(mode)
        passwordField.alpha = CGFloat(mode)
        signInSignUpToggleOutlet.alpha = CGFloat(mode)
        
        globalMode[0] = mode
    }
    
    func setDefaultLoginPageParameters() -> () {
        setMode(0)
    }
    
    func disableAllFields() -> () {
        nameField.isEnabled = false
        emailField.isEnabled = false
        passwordField.isEnabled = false
        signInSignUpToggleOutlet.isEnabled = false
    }
    
    func enableAllFields() -> () {
        nameField.isEnabled = true
        emailField.isEnabled = true
        passwordField.isEnabled = true
        signInSignUpToggleOutlet.isEnabled = true
    }
    
    func signInSignUpToggleHelper() -> () {
        switch signInSignUpToggleOutlet.selectedSegmentIndex {
        case 0:
            print("Sign In Mode");
            nameField.isEnabled = false
            nameField.alpha = 0
            globalMode[1] = 0
        case 1:
            print("Sign Up Mode");
            nameField.isEnabled = true
            nameField.alpha = 1
            globalMode[1] = 1
        default:
            break;
        }
    }
    
    func proceedAsEater() -> () {
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
    func drawUIElements() -> () {
        //Draw lines at the bottom of the text fields
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
