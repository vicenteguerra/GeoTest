//
//  searchResultsController.swift
//  Parkiller Test
//
//  Created by Vicente Guerra on 12/31/16.
//  Copyright © 2016 Vicente Guerra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol LocateOnTheMap{
    func locateWithLongitude(lon: Double, andLatitude: Double, andTitle: String)
}

class searchResultsController: UITableViewController {
    
    
    var searchResults: [String]!
    var delegate: LocateOnTheMap!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        let firstResult: String = self.searchResults[indexPath.row]
        if let correctedAddress = firstResult.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)") {
            Alamofire.request(url).responseJSON { response in
                if let json = response.result.value {
                    let myjson = JSON(json)
                    
                    if let lon = myjson["results"][0]["geometry"]["location"]["lng"].double {
                        self.delegate.locateWithLongitude(lon: lon, andLatitude: myjson["results"][0]["geometry"]["location"]["lat"].double!, andTitle: self.searchResults[indexPath.row])
                    } else {
                        //Print the error
                        print(myjson["results"][0]["geometry"]["location"]["lng"].double)
                    }
                }
            }
        }

    }
    
    func reloadDataWithArray(array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    
}
