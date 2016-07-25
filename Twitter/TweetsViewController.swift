//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/22/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet]?
    
    var tweetsWillBeLoaded = 20
    
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TwitterClient.sharedInstance.getNameWithScreenName("toanqri")
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TweetsViewController.addTweet),
            name: "addTweetNotification", object: nil
        )
        
        let logoImage = UIImage(named: "twitter_logo_blue")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = logoImage
        self.navigationItem.titleView = imageView
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set up Refresh Control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTweets(_:)), forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        fetchHomeTimelineTweets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchHomeTimelineTweets() {
        let parameters: NSDictionary = [
            "count": tweetsWillBeLoaded
        ]
        
        TwitterClient.sharedInstance.homeTimeline(
            parameters,
            success: { (tweets: [Tweet]) -> Void in
                self.tweets = tweets
                self.tableView.reloadData()
            },
            failure: { (error: NSError) in
                print(error)
            }
        )
    }
    
    func fetchMoreHomeTimelineTweets() {
        tweetsWillBeLoaded += 20
        let parameters: NSDictionary = [
            "count": tweetsWillBeLoaded
        ]
        
        TwitterClient.sharedInstance.homeTimeline(
            parameters,
            success: { (tweets: [Tweet]) -> Void in
                self.isMoreDataLoading = false
                self.tweets = tweets
                self.tableView.reloadData()
            },
            failure: { (error: NSError) in
                print(error)
            }
        )
    }
    
    func addTweet(notification: NSNotification) {
        if let newTweet = notification.userInfo!["newTweet"] as? Tweet {
            tweets?.insert(newTweet, atIndex: 0)
            tableView.reloadData()
        }
    }
    
    func refreshTweets(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimeline(
            nil,
            success: { (tweets: [Tweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            },
            failure: { (error: NSError) in
                refreshControl.endRefreshing()
            }
        )
    }
    
    @IBAction func onLogout(sender: UIBarButtonItem) {
        User.currentUser?.logout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetDetailsSegue" {
            let tweetDetailsViewController = segue.destinationViewController as! TweetDetailsViewController
            tweetDetailsViewController.delegate = self
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            tweetDetailsViewController.tweet = tweets![indexPath.row]
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        cell.delegate = self
        cell.tweet = tweets?[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - TweetCellDelegate

extension TweetsViewController: TweetCellDelegate {
    func tweetCellDidUpdateTweet() {
        self.tableView.reloadData()
    }
}

// MARK: - TweetDetailsViewControllerDelegate

extension TweetsViewController: TweetDetailsViewControllerDelegate {
    func tweetDetailsViewControllerDidUpdateTweet() {
        self.tableView.reloadData()
    }
    
    func tweetCellDidReplyToTweet(tweet: Tweet) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tweetComposeViewController = storyboard.instantiateViewControllerWithIdentifier("TweetComposeViewController") as! TweetComposeViewController
        tweetComposeViewController.tweet = tweet
        let navigationController = UINavigationController(rootViewController: tweetComposeViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate

extension TweetsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                fetchMoreHomeTimelineTweets()
            }
        }
    }
}
