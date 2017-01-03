//
//  nearController.swift
//  Parkiller Test
//
//  Created by Vicente Guerra on 1/3/17.
//  Copyright © 2017 Vicente Guerra. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire
import TwitterAPI


extension ViewController{

    func getStaticMap(lat: String, lng: String) -> String{
        return "https://maps.googleapis.com/maps/api/staticmap?center=\(lat),\(lng)&zoom=14&size=500x500&markers=color:red%7Clabel:C%7C\(lat),\(lng)"
    }
    
    func postTweet(tuit: String){
        let client = OAuthClient(
            consumerKey: "Ix3P1xyXtNFhRRHQ1Zdxhn2F1",
            consumerSecret: "LcsQ1wAmbm31JhPQnHSPD9e0ZG15DQvFEqekaNrjq7xL0sBSSR",
            accessToken: "816057034420482048-QuhHIZLIUnnHneZTwtgselx9nsMyYHS",
            accessTokenSecret: "0s9amZoGtk6LqJLzBT6nBscZN4Jq5RXA34rwPtUyDteNi")
        
        let url = "https://api.twitter.com/1.1/statuses/update.json"
        let parameters = ["status": tuit]
        
        Alamofire.request(client.makeRequest(.POST, url: url, parameters: parameters)).responseJSON { response in
            print(response)
        }
    }
    
    //https://api.twitter.com/1.1/statuses/update.json?status=Maybe%20he%27ll%20finally%20find%20his%20keys.%20%23peterfalk
}
