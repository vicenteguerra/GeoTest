//
//  distanceController.swift
//  Parkiller Test
//
//  Created by Vicente Guerra on 1/2/17.
//  Copyright © 2017 Vicente Guerra. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

protocol distanceProperties{
    var color200: UIColor { get }
    var stroke200: UIColor { get }
    var color100: UIColor { get }
    var stroke100: UIColor { get }
    var color50: UIColor { get }
    var stroke50: UIColor { get }
    var color10: UIColor { get }
    var stroke10: UIColor { get }
}

extension ViewController: distanceProperties{
    
    internal var color200: UIColor {
        return UIColor(red: 0.7, green: 0.2, blue: 0.9, alpha: 0.1)
    }
    
    internal var stroke200: UIColor {
        return UIColor(red: 0.7, green: 0.2, blue: 0.9, alpha: 0.8)
    }
    
    internal var color100: UIColor {
        return UIColor(red: 0.5, green: 0.3, blue: 0.8, alpha: 0.1)
    }
    
    internal var stroke100: UIColor {
        return UIColor(red: 0.5, green: 0.3, blue: 0.8, alpha: 0.8)
    }
    
    internal var color50: UIColor {
        return UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 0.1)
    }
    
    internal var stroke50: UIColor {
        return UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 0.8)
    }
    
    internal var color10: UIColor {
        return UIColor(red: 0.1, green: 0.5, blue: 0.6, alpha: 0.1)
    }
    
    internal var stroke10: UIColor {
        return UIColor(red: 0.1, green: 0.5, blue: 0.6, alpha: 0.8)
    }

    
    func drawCircles(){
        let circleCenter : CLLocationCoordinate2D  = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude)
        let circ200 = GMSCircle(position: circleCenter, radius: 200)
        circ200.fillColor = color200
        circ200.strokeColor = stroke200
        circ200.strokeWidth = 1
        circ200.map = self.mapView
        
        let circ100 = GMSCircle(position: circleCenter, radius: 100)
        circ100.fillColor = color100
        circ100.strokeColor = stroke100
        circ100.strokeWidth = 1
        circ100.map = self.mapView
        
        let circ50 = GMSCircle(position: circleCenter, radius: 50)
        circ50.fillColor = color50
        circ50.strokeColor = stroke50
        circ50.strokeWidth = 1
        circ50.map = self.mapView
        
        let circ10 = GMSCircle(position: circleCenter, radius: 10)
        circ10.fillColor = color10
        circ10.strokeColor = stroke10
        circ10.strokeWidth = 1
        circ10.map = self.mapView
    }
    
    func removeCircles(){
        self.mapView.clear()
    }
    
    func showDistance(){
        if(self.markerLocation != nil){
            let distance = round(self.markerLocation!.distance(from: self.location) ) // In Meters
            var color = UIColor.black
            var message = ""
            var alert = false
            
            if(distance > 200){
                message = "Estás muy lejos del punto objetivo"
                alert = false
                if(range != 200){
                    alert = true
                }else{
                    alert = false
                }
                range = 200
            }else if(distance > 100){
                message = "Estás lejos del punto objetivo"
                color = stroke200
                if(range != 100){
                    alert = true
                }else{
                    alert = false
                }
                range = 100
            }else if(distance > 50){
                message = "Estás próximo al punto objetivo"
                color = stroke100
                if(range != 50){
                    alert = true
                }else{
                    alert = false
                }
                range = 50
            }else if(distance > 10){
                message = "Estás muy próximo al punto objetivo"
                color = stroke50
                if(range != 10){
                    alert = true
                }else{
                    alert = false
                }
                range = 10
            }else{
                message = "Estás en el punto objetivo"
                color = stroke10
                if(range != 0){
                    alert = true
                }else{
                    alert = false
                }
                range = 0
            }
            
            if(alert == true){
                sendNotification(subtitle: message, distance: "\(distance) m." )
                if(range == 0){
                    print(getStaticMap(lat: "\(markerLocation!.coordinate.latitude)" , lng: "\(markerLocation!.coordinate.longitude)"))
                }
            }
            infoLabel.text = "\(message)\n \(distance) m."
            infoLabel.textColor = color
        }
    }
    
}
