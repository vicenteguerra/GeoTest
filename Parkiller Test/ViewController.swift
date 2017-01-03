//
//  ViewController.swift
//  Valid Place
//
//  Created by Vicente Guerra on 12/27/16.
//  Copyright © 2016 Vicente Guerra. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import UserNotifications

class ViewController: UIViewController, LocateOnTheMap, UISearchBarDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var locationManager:CLLocationManager!
    var camera: GMSCameraPosition!
    var position: GMSCameraPosition!
    var location: CLLocation!
    var initialCamera: Bool = true
    var markerAddress: String = ""
    var markerLocation: CLLocation? = nil
    
    var searchResultController: searchResultsController!
    var resultsArray = [String]()
    
    var isGrantedNotificationAccess:Bool = false
    var marker: GMSMarker!
    
    @IBOutlet weak var deleteMarkerButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var pinLabel: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        camera = GMSCameraPosition.camera(withLatitude: 19.1143400177539,
                                          longitude: -99.2471251265139, zoom: 12)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        infoLabel.isHidden =  true
        
        marker = GMSMarker()
        deleteMarkerButton.isHidden = true
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
    }
    
    
    @IBAction func markPoint(_ sender: Any) {
        
        marker.position = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude)
        reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude))
        marker.title = "🏁"
        marker.map = mapView
        infoLabel.isHidden = false
        markButton.isHidden = true
        deleteMarkerButton.isHidden = false
        
        self.markerLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)

        showDistance()
        drawCircles()
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.position = position
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchResultController = searchResultsController()
        searchResultController.delegate = self
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToMyLocation(_ sender: Any) {
        camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 14)
        mapView.animate(to: camera)
    }
    
    
    func sendNotification(subtitle: String, distance: String){
        if isGrantedNotificationAccess{
            let content = UNMutableNotificationContent()
            content.title = "Parkiller 🚀"
            content.subtitle = subtitle
            content.body = distance
            content.categoryIdentifier = "message"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 5,
                repeats: false)
            let request = UNNotificationRequest(
                identifier: "10.second.message",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        location = userLocation
        
        if(initialCamera){
            camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude, zoom: 14)
            mapView.camera = camera
            initialCamera = false
        }
        
        if(self.markerLocation != nil){
            showDistance()
        }
        //manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                let lines = address.lines as [String]!
                self.markerAddress = (lines?.joined(separator: "\n"))!
                
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    
    @IBAction func searchAction(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        let searchTextField: UITextField? = searchController.searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)){
            let attributeDict = [NSForegroundColorAttributeName: UIColor.gray]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Buscar...", attributes: attributeDict)
        }
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func removeMarker(_ sender: Any) {
        removeCircles()
        markerLocation = nil
        deleteMarkerButton.isHidden = true
        infoLabel.isHidden = true
        markButton.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil, callback: {results,_ in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                if let result = result as? GMSAutocompletePrediction {
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWithArray(array: self.resultsArray)
        })
    }
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.async {
            self.infoLabel.text = title
            self.camera = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: lon, zoom: 14)
            self.mapView.animate(to: self.camera)
        }
    }
    
}


extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
