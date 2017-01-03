//
//  nearController.swift
//  Parkiller Test
//
//  Created by Vicente Guerra on 1/3/17.
//  Copyright © 2017 Vicente Guerra. All rights reserved.
//

import Foundation

protocol keys {
    var google_maps_api_key: String { get }
}

extension ViewController: keys{
    internal var google_maps_api_key: String {
        get {
            return "AIzaSyA2qFQaOixrlXi6u2ArwKyARpCRE9h0AeQ"
        }
    }

    func getStaticMap(lat: String, lng: String) -> String{
        return "https://maps.googleapis.com/maps/api/staticmap?center=\(lat),\(lng)&zoom=14&size=500x500&markers=color:red%7Clabel:C%7C\(lat),\(lng)"
    }
    
    //https://api.twitter.com/1.1/statuses/update.json?status=Maybe%20he%27ll%20finally%20find%20his%20keys.%20%23peterfalk
}
