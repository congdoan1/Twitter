//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/23/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit

@objc protocol TweetDetailsViewControllerDelegate {
    optional func tweetDetailsViewControllerDidUpdateTweet()
}

class TweetDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: TweetDetailsViewControllerDelegate?
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReply(sender: UIBarButtonItem) {
        replyToTweet()
    }
    
    func replyToTweet() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tweetComposeViewController = storyboard.instantiateViewControllerWithIdentifier("TweetComposeViewController") as! TweetComposeViewController
        tweetComposeViewController.tweet = tweet
        let navigationController = UINavigationController(rootViewController: tweetComposeViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TweetDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetDetailsCell") as! TweetDetailsCell
            cell.selectionStyle = .None
            cell.tweet = tweet
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetStatisticsCell") as! TweetStatisticsCell
            cell.selectionStyle = .None
            cell.tweet = tweet
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetActionsCell") as! TweetActionsCell
            cell.selectionStyle = .None
            cell.delegate = self
            cell.tweet = tweet
            return cell
        }
    }
}

// MARK: - TweetActionsCellDelegate

extension TweetDetailsViewController: TweetActionsCellDelegate {
    func tweetActionsCellDidUpdateTweet(tweet: Tweet) {
        self.tweet = tweet
        self.tableView.reloadData()
        delegate?.tweetDetailsViewControllerDidUpdateTweet!()
    }
    
    func tweetActionsCellDidReplyToTweet() {
        replyToTweet()
    }
}
