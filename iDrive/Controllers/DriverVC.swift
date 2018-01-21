//
//  DriverVC.swift
//  iDrive
//
//  Created by Nishant Hooda on 2018-01-14.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {

    @IBOutlet weak var driverMap: MKMapView!
    @IBOutlet weak var acceptUberButton: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var acceptedUber = false
    private var driverCanceledUber = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.delegate = self
        UberHandler.Instance.observeDriverMessages()
        
    }

    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if coordinate available
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpanMake(0.01, 0.01))
            
            driverMap.setRegion(region, animated: true)
            
            driverMap.removeAnnotations(driverMap.annotations)
            
            if riderLocation != nil{
                if acceptedUber {
                    let riderAnnotation = MKPointAnnotation()
                    riderAnnotation.coordinate = riderLocation!
                    riderAnnotation.title = "Riders Location"
                    driverMap.addAnnotation(riderAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!
            annotation.title = "Rider Location"
            driverMap.addAnnotation(annotation)
        }
    }
    
    func acceptUber(lat: Double, long: Double) {
        if !acceptedUber{
            uberRequest(title: "Uber Request", message: "You have a request for an Uber at this location: Latitude: \(lat) Longitude: \(long)", requestAlive: true)
        }
    }
    
    func riderCanceledUber() {
        if !driverCanceledUber{
            UberHandler.Instance.cancelUberForDriver()
            self.acceptedUber = false
            self.acceptUberButton.isHidden = true
            uberRequest(title: "Uber Canceled", message: "The rider has canceled the Uber", requestAlive: false)
        }
    }
    
    func uberCanceled() {
        acceptedUber = false
        acceptUberButton.isHidden = true
        timer.invalidate()
    }
    
    func updateRiderLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @objc func updateDriverLocation(){
        UberHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }

    @IBAction func cancelUber(_ sender: Any) {
        if acceptedUber{
            driverCanceledUber = true;
            acceptUberButton.isHidden = true
            UberHandler.Instance.cancelUberForDriver()
            timer.invalidate()
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut(){
            if acceptedUber{
                acceptUberButton.isHidden = true
                UberHandler.Instance.cancelUberForDriver()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }else{
            uberRequest(title: "Error logging out", message: "Please try again later", requestAlive: false)
        }
    }
    
    private func uberRequest (title:String, message: String, requestAlive: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler:
            {(alertAction: UIAlertAction) in
                self.acceptedUber = true
                self.acceptUberButton.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(DriverVC.updateDriverLocation), userInfo: nil, repeats: true)
                
                UberHandler.Instance.uberAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude))
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)

            alert.addAction(accept)
            alert.addAction(cancel)
            
        }else{
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
        }
        
        present(alert, animated: true, completion: nil)
    }
    

}
