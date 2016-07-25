//
//  TweetActionsCell.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/23/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit

@objc protocol TweetActionsCellDelegate {
    optional func tweetActionsCellDidUpdateTweet(tweet: Tweet)
    optional func tweetActionsCellDidReplyToTweet()
}

class TweetActionsCell: UITableViewCell {
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: TweetActionsCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            if let retweeted = tweet.retweeted {
                if retweeted {
                    retweetButton.setImage(UIImage(named: "retweet-action-on"), forState: .Normal)
                    retweetButton.setImage(UIImage(named: "retweet-action-on-pressed"), forState: .Selected)
                    retweetButton.setImage(UIImage(named: "retweet-action-inactive"), forState: .Disabled)
                } else {
                    retweetButton.setImage(UIImage(named: "retweet-action"), forState: .Normal)
                    retweetButton.setImage(UIImage(named: "retweet-action-pressed"), forState: .Selected)
                    retweetButton.setImage(UIImage(named: "retweet-action-inactive"), forState: .Disabled)
                }
            }
            
            if let favorited = tweet.favorited {
                if favorited {
                    favoriteButton.setImage(UIImage(named: "like-action-on"), forState: .Normal)
                } else {
                    favoriteButton.setImage(UIImage(named: "like-action"), forState: .Normal)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onReply(sender: UIButton) {
        delegate?.tweetActionsCellDidReplyToTweet!()
    }
    
    @IBAction func onRetweet(sender: UIButton) {
        let parameters: NSDictionary = [
            "id": tweet.id!
        ]
        if let retweeted = tweet.retweeted {
            if retweeted {
                TwitterClient.sharedInstance.unretweet(
                    parameters,
                    success: { (tweet: Tweet) -> Void in
                        self.tweet.retweeted = false
                        self.tweet.retweetsCount = self.tweet.retweetsCount! - 1
                        self.delegate?.tweetActionsCellDidUpdateTweet!(self.tweet)
                    },
                    failure: { (error: NSError) -> Void in
                        print("Unretweet failed \(error.localizedDescription)")
                    }
                )
            } else {
                TwitterClient.sharedInstance.retweet(
                    parameters,
                    success: { (tweet: Tweet) -> Void in
                        self.tweet.retweeted = true
                        self.tweet.retweetsCount = self.tweet.retweetsCount! + 1
                        self.delegate?.tweetActionsCellDidUpdateTweet!(self.tweet)
                    },
                    failure: { (error: NSError) -> Void in
                        print("Retweet failed \(error.localizedDescription)")
                    }
                )
            }
        }
    }
    
    @IBAction func onFavorite(sender: UIButton) {
        let parameters: NSDictionary = [
            "id": tweet.id!
        ]
        if let favorited = tweet.favorited {
            if favorited {
                TwitterClient.sharedInstance.unfavorite(
                    parameters,
                    success: { (tweet: Tweet) -> Void in
                        self.tweet.favorited = false
                        self.tweet.favoritesCount = self.tweet.favoritesCount! - 1
                        self.delegate?.tweetActionsCellDidUpdateTweet!(self.tweet)
                    },
                    failure: { (error: NSError) -> Void in
                        print("Unfavorite failed \(error.localizedDescription)")
                    }
                )
            } else {
                TwitterClient.sharedInstance.favorite(
                    parameters,
                    success: { (tweet: Tweet) -> Void in
                        self.tweet.favorited = true
                        self.tweet.favoritesCount = self.tweet.favoritesCount! + 1
                        self.delegate?.tweetActionsCellDidUpdateTweet!(self.tweet)
                    },
                    failure: { (error: NSError) -> Void in
                        print("Unfavorite failed \(error.localizedDescription)")
                    }
                )
            }
        }
    }
}
