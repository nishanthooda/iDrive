//
//  UberHandler.swift
//  iDrive
//
//  Created by Nishant Hooda on 2018-01-14.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class{
    func acceptUber(lat: Double, long: Double)
    func riderCanceledUber();
    func uberCanceled();
    func updateRiderLocation (lat: Double, long: Double)
}

class UberHandler{
    private static let _instance = UberHandler()
    
    static var Instance: UberHandler {
        return _instance
    }
    
    weak var delegate: UberController?
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    func observeDriverMessages(){
        //RIDER UBER REQUEST
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded){
            (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let latitude = data[Constants.latitude] as? Double{
                    if let longitude = data[Constants.longitude] as? Double {
                        self.delegate?.acceptUber(lat: latitude, long: longitude)
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.rider = name;
                }
            }
            //Rider Cancelled Uber
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: {(snapshot: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider{
                            self.rider = "";
                            self.delegate?.riderCanceledUber()
                        }
                    }
                }
            })
        }
        //Rider Updating Location
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged){(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.latitude] as? Double {
                    if let long = data[Constants.longitude] as? Double{
                        self.delegate?.updateRiderLocation(lat: lat, long: long)
                    }
                }
            }
            
            
        }
        
        //Driver Accepts Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded){ (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver{
                        self.driver_id = snapshot.key
                    }
                }
            }
        }
        
        //Driver Canceled Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved){ (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver {
                        self.delegate?.uberCanceled()
                    }
                }
            }
        }
    }//observeDriverMessages
    
    func uberAccepted(lat: Double, long: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: driver, Constants.latitude: lat, Constants.longitude: long]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data);
    }//uberAccepted
    
    func cancelUberForDriver(){
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue()
    }
    
    func updateDriverLocation(lat: Double, long: Double){
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.latitude: lat, Constants.longitude: long])
    }
    
}

