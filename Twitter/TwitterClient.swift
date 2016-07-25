//
//  TwitterClient.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/19/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

let twitterBaseURL = NSURL(string: "https://api.twitter.com")
let twitterConsumerKey = "EMEZItiv4Onf69ooxowCANKPn"
let twitterConsumerSecret = "NiZVZg4iEVqkBxNb93BJjyS0ztBBGb4aAa3kMCAlmN0D8l3XNA"
let requestToken = "/oauth/request_token"
let authorize = "/oauth/authorize"
let accessToken = "/oauth/access_token"

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(
        baseURL: twitterBaseURL,
        consumerKey: twitterConsumerKey,
        consumerSecret: twitterConsumerSecret
    )
    
    var loginSuccess: (() -> ())?
    var loginFailure: (NSError -> ())?
    
    func login(success: () -> (), failure: NSError -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestTokenWithPath(
            requestToken,
            method: "GET",
            callbackURL: NSURL(string: "coderschooltwitter://oauth"),
            scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                let authorizeURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
                UIApplication.sharedApplication().openURL(authorizeURL)
            },
            failure: { (error: NSError?) -> Void in
                print("Error: \(error?.localizedDescription)")
                self.loginFailure?(error!)
            }
        )
    }
    
    func homeTimeline(parameters: NSDictionary?, success: ([Tweet]) -> (), failure: NSError -> ()) {
        TwitterClient.sharedInstance.GET(
            "/1.1/statuses/home_timeline.json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let dictionaries = response as! [NSDictionary]
                print(dictionaries)
                let tweets = Tweet.tweetsWithArray(dictionaries)
                success(tweets)
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            }
        )
    }
    
    func newTweet(parameters: NSDictionary, success: (Tweet) -> (), failure: NSError -> ()) {
        POST(
            "/1.1/statuses/update.json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                success(tweet)
            },
            failure:{ (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            }
        )
    }
    
    func retweet(parameters: NSDictionary, success: (Tweet) -> (), failure: NSError -> ()) {
        POST(
            "/1.1/statuses/retweet/\(parameters["id"]!).json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                success(tweet)
            },
            failure:{ (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            }
        )
    }
    
    func unretweet(parameters: NSDictionary, success: (Tweet) -> (), failure: NSError -> ()) {
        POST(
            "/1.1/statuses/unretweet/\(parameters["id"]!).json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                success(tweet)
            },
            failure:{ (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            }
        )
    }
    
    func favorite(parameters: NSDictionary, success: (Tweet) -> (), failure: NSError -> ()) {
        POST(
            "/1.1/favorites/create.json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                success(tweet)
            },
            failure:{ (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            }
        )
    }
    
    func unfavorite(parameters: NSDictionary, success: (Tweet) -> (), failure: NSError -> ()) {
        POST(
            "/1.1/favorites/destroy.json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                success(tweet)
            },
            failure:{ (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            }
        )
    }
    
    func getNameWithScreenName(screenName: String) {
        let parameters: NSDictionary = [
            "screen_name": screenName
        ]
        GET(
            "/1.1/users/show.json",
            parameters: parameters,
            progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                print("show @\(screenName): \(response as? NSDictionary)")
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) in
                
            }
        )
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath(
            accessToken,
            method: "POST",
            requestToken: BDBOAuth1Credential(queryString: url.query),
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
                TwitterClient.sharedInstance.GET(
                    "/1.1/account/verify_credentials.json",
                    parameters: nil,
                    progress: nil,
                    success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                        let user = User(dictionary: response as! NSDictionary)
                        User.currentUser = user
                        self.loginSuccess!()
                    },
                    failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                        print("error: \(error.localizedDescription)")
                        self.loginFailure?(error)
                    }
                )
            },
            failure: { (error: NSError?) -> Void in
                print("error: \(error?.localizedDescription)")
        })
    }
}