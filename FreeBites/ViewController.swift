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

class ViewController: UIViewController, MKMapViewDelegate {

    //Database
    var ref = FIRDatabase.database().reference()
    
    //Properties
    let view1 = UIView()
    
    
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
    
    @IBOutlet weak var settingsOutlet: UIView!
    @IBOutlet weak var foodProfilePicture: UIImageView!
    @IBOutlet weak var dismissSettingsOutlet: UIButton!
    //MARK: - Actions
    
    @IBAction func logOut(_ sender: Any) {
        logoutHelper()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }

    func quickHelper() {
        print("Location: \(locationManager.location!)")
    }
    @IBAction func showSettings(_ sender: Any) {
        let screenWidth = 375.0
        let screenHeight = 687.0
        settingsOutlet.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.settingsOutlet.frame = CGRect(x: screenWidth * 0.34, y: 0, width: screenWidth * (0.67), height: screenHeight)
            self.settingsOutlet.alpha = 1
            self.dismissSettingsOutlet.isEnabled = true
            self.dismissSettingsOutlet.isHidden = false
            self.dismissSettingsOutlet.alpha = 0.5
        }
    }
    @IBAction func dismissSettings(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            let screenWidth = 375.0
            let screenHeight = 687.0
            self.settingsOutlet.frame = CGRect(x: screenWidth, y: 0, width: screenWidth * (0.67), height: screenHeight)
            self.settingsOutlet.alpha = 0
            self.dismissSettingsOutlet.alpha = 0
            
        }
        self.dismissSettingsOutlet.isEnabled = false
    }
    
    //MARK: - Application
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForCurrentUser()
        checkEmailVerification()
        createRandomFood()
        fetchAllActiveFoods()
        
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
        
        //Handle Settings View
        let screenWidth = 375.0
        let screenHeight = 687.0
        settingsOutlet.layer.cornerRadius = 15
        settingsOutlet.isHidden = true
        settingsOutlet.frame = CGRect(x: screenWidth, y: 0, width: screenWidth * (0.66), height: screenHeight - 20)
        dismissSettingsOutlet.alpha = 0
        dismissSettingsOutlet.isEnabled = false
        dismissSettingsOutlet.isHidden = true
        

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
        addFoodToDatabase(foodName: "Pizza", lat: 33.7748, lon: -84.3964)
    }
    
    func addFoodToDatabase(foodName:String, lat:Double, lon:Double) {
        self.ref.child("food").childByAutoId().setValue([
            "name"  : foodName,
            "lat"   : lat,
            "lon"   : lon])
    }
    
    func dropPinForFood(foodID: String) {
        FIRDatabase.database().reference().child("food").child(foodID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let obtainedLat = value?.value(forKey: "lat") as? Double ?? 0.0
            let obtainedLon = value?.value(forKey: "lon") as? Double ?? 0.0
            let obtainedName = value?.value(forKey: "name") as? String ?? ""
            let foodAnnotation = MKPointAnnotation()
            foodAnnotation.title = obtainedName
            foodAnnotation.subtitle = "This is a subtitle"
            foodAnnotation.coordinate = CLLocationCoordinate2D(latitude: obtainedLat, longitude: obtainedLon)
            self.map.addAnnotation(foodAnnotation)
        })
    }
    
    func fetchAllActiveFoods() {
        FIRDatabase.database().reference().child("food").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //Find all the food entries.
            for ID in value?.allKeys ?? [""] {
                self.dropPinForFood(foodID: ID as! String)
            }
        })
    }
    
    func setFoodAnnotationInfo(foodAnnotation: MKPointAnnotation, title:String, subtitle:String) {
        foodAnnotation.title = title
        foodAnnotation.subtitle = subtitle
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotationTitle = view.annotation?.title {
            print("User tapped on annotation with title: \(annotationTitle!)")
        }
        displayFoodInformation(selectedAnnotation: view)
        
    }
    
    func displayFoodInformation(selectedAnnotation: MKAnnotationView) {
        print("Display food information")
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


