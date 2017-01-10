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

    //Database
    var ref = FIRDatabase.database().reference()
    
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
    @IBOutlet weak var mapViewInformationSpace: UIImageView!
    
    @IBOutlet weak var foodProfilePicture: UIImageView!
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
        createRandomFood()
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleMapRegion), userInfo: nil, repeats: false)
        
        //Handle Corner Radii
        map.layer.cornerRadius = 15
        map.clipsToBounds = true
        welcomeLabel.layer.cornerRadius = 15
        welcomeLabel.clipsToBounds = true
        mapViewInformationSpace.clipsToBounds = true
        mapViewInformationSpace.layer.cornerRadius = 15
        foodProfilePicture.clipsToBounds = true
        foodProfilePicture.layer.cornerRadius = 15

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
                self.updateWelcomeMessage("Current User: Guest")
            }
            //self.updateWelcomeMessage(message)
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
        
        //MARK: - TODO: Integrate latitude and longitude as class properties.
        
        var lat = 33.7756
        var lon = -84.3963
        var coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegionMakeWithDistance(coord, 2500, 2500)
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
    }
    
    
    //This is only a temporary function. Get rid of this later.
    func createRandomFood() {
        //33.7773° N, 84.3962° W
        let klausLat = 33.7748
        let klausLon = -84.3964
        let foodName = "Pizza"
        self.ref.child("food").child("000001").setValue([
            "name"  : foodName,
            "lat"   : klausLat,
            "lon"   : klausLon])
        let foodAnnotation = MKPointAnnotation()
        
        
        var wantedFood = "000001"
        FIRDatabase.database().reference().child("food").child(wantedFood).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let obtainedLat = value?.value(forKey: "lat") as? Double ?? 0.0
            let obtainedLon = value?.value(forKey: "lon") as? Double ?? 0.0
            foodAnnotation.coordinate = CLLocationCoordinate2D(latitude: obtainedLat, longitude: obtainedLon)
            self.map.addAnnotation(foodAnnotation)
        })
        
        
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


