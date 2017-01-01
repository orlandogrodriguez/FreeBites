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
import Firebase
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: - Properties
    var locationManager: CLLocationManager!
    
    //MARK: - Outlets
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Actions
    
    @IBAction func logOut(_ sender: Any) {
        logoutHelper()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }

    
    //MARK: - Application
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForCurrentUser()
        checkEmailVerification()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        self.map.setRegion(region, animated: true)
    }
    
    //MARK: - Helper Functions
    
    func checkForCurrentUser() -> () {
        
        var message = ""
        var curUserName = ""
        
        _ = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if FIRAuth.auth()?.currentUser != nil {
                let curUserUID = FIRAuth.auth()?.currentUser?.uid
                FIRDatabase.database().reference().child("users").child(curUserUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    print (snapshot)
                    
                    let value = snapshot.value as? NSDictionary
                    curUserName = value?.value(forKey: "name") as? String ?? ""
                    message = "Current User: \(curUserName)"
                    self.updateWelcomeMessage(message)
                    
                })
            } else {
                //message = "Current User: Guest"
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
    
    func checkEmailVerification() -> () {
        if let user = FIRAuth.auth()?.currentUser {
            if !user.isEmailVerified {
                print("Please verify email address")
            } else {
                print("Email has been verified! You're good to go!")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

