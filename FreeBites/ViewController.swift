//
//  ViewController.swift
//  FreeBites
//
//  Created by Orlando G. Rodriguez on 12/25/16.
//  Copyright © 2016 Orlando G. Rodriguez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    //MARK: - Actions
    
    @IBAction func logOut(_ sender: Any) {
        logoutHelper()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }

    
    //MARK: - Application
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForCurrentUser()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: - Helper Functions
    
    func checkForCurrentUser() -> () {
        var message = ""
        _ = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if FIRAuth.auth()?.currentUser != nil {
                message = "Welcome to the main menu, \(user!.email)!"
            } else {
                message = "Welcome to the main menu, guest!"
            }
            self.updateWelcomeMessage(message)
            print (message)
        }
    }
    
    func logoutHelper() -> () {
        if FIRAuth.auth()?.currentUser != nil {
            try! FIRAuth.auth()?.signOut()
        } else {
            //Just proceed back to main menu
        }
    }
    
    func updateWelcomeMessage(_ msg:String) -> () {
        welcomeLabel.text = msg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

