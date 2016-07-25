//
//  Tweet.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/22/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import Foundation

class Tweet: NSObject {
    var id: Int?
    var user: User?
    var text: String?
    
    var urls: [NSDictionary]?
    var media: [NSDictionary]?
    
    var userMentions: [NSDictionary]?
    var inReplyToScreenName: String?
    
    var timestamp: NSDate?
    
    var retweetsCount: Int?
    var favoritesCount: Int?
    var retweeted: Bool?
    var favorited: Bool?
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        
        urls = dictionary["entities"]?["urls"] as? [NSDictionary]
        media = dictionary["entities"]?["media"] as? [NSDictionary]
        userMentions = dictionary["entities"]?["user_mentions"] as? [NSDictionary]
        
        inReplyToScreenName = dictionary["in_reply_to_screen_name"] as? String
        
        if let createAtString = dictionary["created_at"] as? String {
            let formater = NSDateFormatter()
            formater.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formater.dateFromString(createAtString)
        }
        
        retweetsCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
    
    class func timeSince(date: NSDate) -> String {
        var unit = "s"
        var timeSince = abs(date.timeIntervalSinceNow as Double) // seconds
        
        let calculateTime = intervalTime(unit, value: timeSince)
        
        while (calculateTime != true) {
            unit = "m"
            timeSince = round(timeSince/60)
            if intervalTime(unit, value: timeSince) {
                break;
            }
            
            unit = "h"
            timeSince = round(timeSince/60)
            if intervalTime(unit, value: timeSince) {
                break;
            }
            
            unit = "d"
            timeSince = round(timeSince/24)
            if intervalTime(unit, value: timeSince) {
                break;
            }
            
            unit = "w"
            timeSince = round(timeSince/7)
            if intervalTime(unit, value: timeSince) {
                break;
            }
            
            (unit, timeSince) = localizedDate(date);
            break
        }
        
        let value = Int(timeSince)
        return "\(value)\(unit)"
    }
    
    class func intervalTime(unit: String, value: Double) -> Bool {
        let value = Int(round(value))
        
        switch unit {
        case "s":
            return value < 60
        case "m":
            return value < 60
        case "h":
            return value < 24
        case "d":
            return value < 7
        case "w":
            return value < 4
        default:
            return true
        }
    }
    
    class func localizedDate(date: NSDate) -> (unit: String, timeSince: Double) {
        var unit = "/"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M"
        let timeSince = Double(formatter.stringFromDate(date))!
        formatter.dateFormat = "d/yy"
        unit += formatter.stringFromDate(date)
        return (unit, timeSince)
    }
}