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
import QuartzCore

class ViewController: UIViewController {

    //Properties
    
    //location manager
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = 10.0  // Movement threshold for new events
        //  _locationManager.allowsBackgroundLocationUpdates = true // allow in background
        
        return _locationManager
    }()

    
    //MARK: - Outlets
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Actions
    
    @IBAction func logOut(_ sender: Any) {
        logoutHelper()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }

    func quickHelper() {
        print("Location: \(locationManager.location!)")
    }
    
    //MARK: - Application
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForCurrentUser()
        checkEmailVerification()
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleMapRegion), userInfo: nil, repeats: false)
        
        map.layer.cornerRadius = 12
        map.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //allow location use
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
    
    func handleMapRegion() {
        var lat = 33.7756
        var lon = -84.3963
        var coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegionMakeWithDistance(coord, 2500, 2500)
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            
            print("**********************")
            print("Long \(location.coordinate.longitude)")
            print("Lati \(location.coordinate.latitude)")
            print("Alt \(location.altitude)")
            print("Sped \(location.speed)")
            print("Accu \(location.horizontalAccuracy)")
            
            print("**********************")
            
            
        }
    }
    
}


