//
//  User.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/19/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import Foundation

var _currentUser: User?
var currentUserKey = "CurrentUser"

class User {
    var dictionary: NSDictionary
    
    var name: String?
    var screenName: String?
    var profileImageURL: NSURL?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let imageURL = dictionary["profile_image_url"] as? String {
            profileImageURL = NSURL(string: imageURL)
        } else {
            profileImageURL = nil
        }
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogoutNotification", object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let userData = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if userData != nil {
                    var dictionary: NSDictionary?
                    do {
                        dictionary = try NSJSONSerialization.JSONObjectWithData(userData!, options: NSJSONReadingOptions()) as? NSDictionary
                    } catch {
                        print("Error deserializing user data")
                    }
                    _currentUser = User(dictionary: dictionary!)
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            if _currentUser != nil {
                var data: NSData?
                do {
                    data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions())
                } catch {
                    print("Error serializing user JSON")
                }
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}