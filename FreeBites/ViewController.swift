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
    
////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////UI Variables/////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

    var UIPhase     = 0
    
    //Global Variables
    let margin:Double      = 20
    let submargin:Double   = 10
    var wView:Double       = 375
    var hView:Double       = 687
    var wStatus:Double     = 375
    var hStatus:Double     = 20
    var wNavigation:Double = 375
    var hNavigation:Double = 44
    var wTab:Double        = 375
    var hTab:Double        = 44
    
    //Map Variables
    var wMap:Double = 0
    var hMap:Double = 0
    var xMap:Double = 0
    var yMap:Double = 0
    var aMap:Double = 0
    
    //Food Description Variables
    var wFoodDescriptionView:Double = 0
    var hFoodDescriptionView:Double = 0
    var xFoodDescriptionView:Double = 0
    var yFoodDescriptionView:Double = 0
    var aFoodDescriptionView:Double = 0
    
    
    //Food Picture Variables
    var wFoodPicture:Double = 0
    var hFoodPicture:Double = 0
    var xFoodPicture:Double = 0
    var yFoodPicture:Double = 0
    var aFoodPicture:Double = 0
    
    //Time Button Variables
    var wTimeButton:Double = 0
    var hTimeButton:Double = 0
    var xTimeButton:Double = 0
    var yTimeButton:Double = 0
    var aTimeButton:Double = 0
    
    //Directions Button Variables
    var wDirectionsButton:Double = 0
    var hDirectionsButton:Double = 0
    var xDirectionsButton:Double = 0
    var yDirectionsButton:Double = 0
    var aDirectionsButton:Double = 0
    
    //Food Description Labels Variables
    var xFoodName:Double = 0
    var yFoodName:Double = 0
    var wFoodName:Double = 0
    var hFoodName:Double = 0
    var aFoodName:Double = 0
    
    var xProviderName:Double = 0
    var yProviderName:Double = 0
    var wProviderName:Double = 0
    var hProviderName:Double = 0
    var aProviderName:Double = 0
    
    var xFoodDescription:Double = 0
    var yFoodDescription:Double = 0
    var wFoodDescription:Double = 0
    var hFoodDescription:Double = 0
    var aFoodDescription:Double = 0
    
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
    

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
    @IBOutlet weak var providerNameOutlet: UILabel!
    @IBOutlet weak var foodDescriptionOutlet: UILabel!
    @IBOutlet weak var timeButtonOutlet: UIButton!
    @IBOutlet weak var directionsButtonOutlet: UIButton!
    @IBOutlet weak var mapListTabBar: UITabBar!
    
    //MARK: - Actions
    @IBAction func logOut(_ sender: Any) {
        logoutHelper()
        performSegue(withIdentifier: "logoutSegue", sender: self)
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
        
        UIPhase = 0
        UI_UpdatePositions(phase: UIPhase)
        
        checkForCurrentUser()
        checkEmailVerification()
        createRandomFood()
        fetchAllActiveFoods()
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleMapRegion), userInfo: nil, repeats: false)
        
        //Handle Corner Radii
        map.layer.cornerRadius = 15
        map.clipsToBounds = true
        mapViewInformationSpace.clipsToBounds = true
        mapViewInformationSpace.layer.cornerRadius = 15
        foodProfilePicture.clipsToBounds = true
        foodProfilePicture.layer.cornerRadius = 15
        timeButtonOutlet.clipsToBounds = true
        timeButtonOutlet.layer.cornerRadius = 15
        directionsButtonOutlet.clipsToBounds = true
        directionsButtonOutlet.layer.cornerRadius = 15
        
        //Handle Settings View
        let screenWidth = 375.0
        let screenHeight = 687.0
        settingsOutlet.layer.cornerRadius = 15
        settingsOutlet.isHidden = true
        settingsOutlet.frame = CGRect(x: screenWidth, y: 0, width: screenWidth * (0.66), height: screenHeight - 20)
        dismissSettingsOutlet.alpha = 0
        dismissSettingsOutlet.isEnabled = false
        dismissSettingsOutlet.isHidden = true
        
        //Handle Tab View
        

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
                    message = "Hey there, \(curUserName)! Tap on a FreeBite to get started!"
                    self.updateWelcomeMessage(message)
                    
                })
            } else {
                //message = "Current User: Guest"
                self.updateWelcomeMessage("Feeling hungry? Tap on a FreeBite to get started!")
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
        
        let lat = 33.7756
        let lon = -84.3963
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegionMakeWithDistance(coord, 2500, 2500)
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
    }
    
    
    //This is only a temporary function. Get rid of this later.
    func createRandomFood() {
        addFoodToDatabase(foodName: "Pizza", creator: "GT-SHPE", description: "Get free papa john's pizza at our weekly meeting!", lat: 33.7748, lon: -84.3964)
        addFoodToDatabase(foodName: "Cookies", creator: "iOS Gatech", description: "Free Insomnia cookies at Klaus 1456!", lat: 33.7773, lon: -84.3962)
    }
    
    func addFoodToDatabase(foodName:String, creator:String, description:String, lat:Double, lon:Double) {
        self.ref.child("food").childByAutoId().setValue([
            "name"          : foodName,
            "creator"       : creator,
            "description"   : description,
            "lat"           : lat,
            "lon"           : lon])
    }
    
    func dropPinForFood(foodID: String) {
        FIRDatabase.database().reference().child("food").child(foodID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let obtainedLat = value?.value(forKey: "lat") as? Double ?? 0.0
            let obtainedLon = value?.value(forKey: "lon") as? Double ?? 0.0
            let obtainedName = value?.value(forKey: "name") as? String ?? ""
            let foodAnnotation = MKPointAnnotation()
            foodAnnotation.title = obtainedName
            foodAnnotation.subtitle = foodID
            
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
    
    func fetchFoodInfoForSinglePin(foodID:String) {
        FIRDatabase.database().reference().child("food").child(foodID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //Find all the food entries.
            let foodTitle:String = (value?.value(forKey: "name")) as! String
            let providerName:String = (value?.value(forKey: "creator")) as! String
            let foodDescription:String = (value?.value(forKey: "description")) as! String
            self.welcomeLabel.text = foodTitle
            self.providerNameOutlet.text = providerName
            self.foodDescriptionOutlet.text = foodDescription
            
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if UIPhase != 1 {
            UIPhase = 1
            UI_UpdatePositions(phase: UIPhase)
        }
        displayFoodInformation(selectedAnnotation: view)
        view.setSelected(true, animated: true)
        view.image = UIImage(named: "BiteMark_Selected")
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if UIPhase != 0 {
            UIPhase = 0
            UI_UpdatePositions(phase: UIPhase)
        }
        view.setSelected(false, animated: true)
        view.image = UIImage(named: "BiteMark")
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = false
            annotationView.image = UIImage(named: "BiteMark")
        }
        
        return annotationView
    }
    
    func displayFoodInformation(selectedAnnotation: MKAnnotationView) {
        fetchFoodInfoForSinglePin(foodID: ((selectedAnnotation.annotation?.subtitle)!)!)
        
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////UI Functions/////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    
    func UI_UpdatePositions(phase:Int) {
        switch phase {
        case 0:
            wMap = wView - (2 * margin)
            hMap = wMap
            xMap = margin
            yMap = ((hView - hTab) / 2) - (hMap / 2) + margin
            aMap = 1
            
            wFoodDescriptionView = wView - (2 * margin)
            hFoodDescriptionView = 0
            xFoodDescriptionView = margin
            yFoodDescriptionView = (((hView - hTab) - (hStatus + hNavigation)) / 2) - (hFoodDescriptionView / 2)
            aFoodDescriptionView = 0
            
            wFoodPicture = hFoodDescriptionView
            hFoodPicture = 0
            xFoodPicture = xFoodDescriptionView
            yFoodPicture = yFoodDescriptionView
            aFoodPicture = 0
            
            wTimeButton = (wMap / 2) - (submargin / 2)
            hTimeButton = 0
            xTimeButton = margin
            yTimeButton = (((hView - hTab) - (hStatus + hNavigation)) / 2) - (hTimeButton / 2)
            aTimeButton = 0
            
            wDirectionsButton = (wMap / 2) - (submargin / 2)
            hDirectionsButton = 0
            xDirectionsButton = wView - margin - wDirectionsButton
            yDirectionsButton = (((hView - hTab) - (hStatus + hNavigation)) / 2) - (hDirectionsButton / 2)
            aDirectionsButton = 0
            
            xFoodName = xFoodPicture + wFoodPicture + (submargin / 2)
            yFoodName = yFoodPicture + (submargin / 2)
            wFoodName = wFoodDescriptionView - wFoodPicture - submargin
            hFoodName = (hFoodDescriptionView - margin) * 0.25
            aFoodName = 0
            
            xProviderName = xFoodPicture + wFoodPicture + (submargin / 2)
            yProviderName = yFoodPicture + (submargin / 2) + hFoodName
            wProviderName = wFoodDescriptionView - wFoodPicture - submargin
            hProviderName = (hFoodDescriptionView - margin) * 0.15
            aProviderName = 0
            
            xFoodDescription = xFoodPicture + wFoodPicture + (submargin / 2)
            yFoodDescription = yFoodPicture + submargin + hFoodName + hProviderName
            wFoodDescription = wFoodDescriptionView - wFoodPicture - submargin
            hFoodDescription = (hFoodDescriptionView - margin) * 0.6
            aFoodDescription = 0

        case 1:
            wMap = wView - (2 * margin)
            hMap = wMap
            xMap = margin
            yMap = hStatus + hNavigation + margin
            aMap = 1
            
            wFoodDescriptionView = wView - (2 * margin)
            hFoodDescriptionView = ((hView - hTab) - (hStatus + hNavigation + margin + hMap + (submargin * 1.5))) * 0.5
            xFoodDescriptionView = margin
            yFoodDescriptionView = hStatus + hNavigation + margin + hMap + submargin
            aFoodDescriptionView = 1
            
            wFoodPicture = hFoodDescriptionView
            hFoodPicture = hFoodDescriptionView
            xFoodPicture = xFoodDescriptionView
            yFoodPicture = yFoodDescriptionView
            aFoodPicture = 1
            
            wTimeButton = (wMap / 2) - (submargin / 2)
            hTimeButton = ((hView - hTab - margin) - (hStatus + hNavigation + margin  + hMap + (submargin * 1.5))) * 0.3
            xTimeButton = margin
            yTimeButton = yFoodDescriptionView + hFoodDescriptionView + submargin
            aTimeButton = 1
            
            wDirectionsButton = (wMap / 2) - (submargin / 2)
            hDirectionsButton = hTimeButton
            xDirectionsButton = wView - margin - wDirectionsButton
            yDirectionsButton = yTimeButton
            aDirectionsButton = 1
            
            xFoodName = xFoodPicture + wFoodPicture + (submargin / 2)
            yFoodName = yFoodPicture + (submargin / 2)
            wFoodName = wFoodDescriptionView - wFoodPicture - submargin
            hFoodName = (hFoodDescriptionView - margin) * 0.25
            aFoodName = 1
            
            xProviderName = xFoodPicture + wFoodPicture + (submargin / 2)
            yProviderName = yFoodPicture + (submargin / 2) + hFoodName
            wProviderName = wFoodDescriptionView - wFoodPicture - submargin
            hProviderName = (hFoodDescriptionView - margin) * 0.15
            aProviderName = 1
            
            xFoodDescription = xFoodPicture + wFoodPicture + (submargin / 2)
            yFoodDescription = yFoodPicture + submargin + hFoodName + hProviderName
            wFoodDescription = wFoodDescriptionView - wFoodPicture - submargin
            hFoodDescription = (hFoodDescriptionView - submargin) * 0.6
            aFoodDescription = 1
            
        default:
            break
        }
        UI_AinamtePositions()
    }
    
    func UI_AinamtePositions() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.map.frame = CGRect(x: self.xMap, y: self.yMap, width: self.wMap, height: self.hMap)
            self.mapViewInformationSpace.frame = CGRect(x: self.xFoodDescriptionView, y: self.yFoodDescriptionView, width: self.wFoodDescriptionView, height: self.hFoodDescriptionView)
            self.foodProfilePicture.frame = CGRect(x: self.xFoodPicture, y: self.yFoodPicture, width: self.wFoodPicture, height: self.hFoodPicture)
            self.timeButtonOutlet.frame = CGRect(x: self.xTimeButton, y: self.yTimeButton, width: self.wTimeButton, height: self.hTimeButton)
            self.directionsButtonOutlet.frame = CGRect(x: self.xDirectionsButton, y: self.yDirectionsButton, width: self.wDirectionsButton, height: self.hDirectionsButton)
            self.welcomeLabel.frame = CGRect(x: self.xFoodName, y: self.yFoodName, width: self.wFoodName, height: self.hFoodName)
            self.providerNameOutlet.frame = CGRect(x: self.xProviderName, y: self.yProviderName, width: self.wProviderName, height: self.hProviderName)
            self.foodDescriptionOutlet.frame = CGRect(x: self.xFoodDescription, y: self.yFoodDescription, width: self.wFoodDescription, height: self.hFoodDescription)
            
            self.map.alpha = CGFloat(self.aMap)
            self.mapViewInformationSpace.alpha = CGFloat(self.aFoodDescriptionView)
            self.foodProfilePicture.alpha = CGFloat(self.aFoodPicture)
            self.timeButtonOutlet.alpha = CGFloat(self.aTimeButton)
            self.directionsButtonOutlet.alpha = CGFloat(self.aDirectionsButton)
            self.welcomeLabel.alpha = CGFloat(self.aFoodName)
            self.welcomeLabel.font = self.welcomeLabel.font.withSize(CGFloat(self.hFoodName))
            self.providerNameOutlet.alpha = CGFloat(self.aProviderName)
            self.providerNameOutlet.font = self.providerNameOutlet.font.withSize(CGFloat(self.hProviderName))
            self.foodDescriptionOutlet.alpha = CGFloat(self.aFoodDescription)
            
        })
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////


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


