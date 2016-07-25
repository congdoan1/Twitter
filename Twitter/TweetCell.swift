//
//  TweetCell.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/22/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    optional func tweetCellDidUpdateTweet()
    optional func tweetCellDidReplyToTweet(tweet: Tweet)
}

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timeSinceLabel: UILabel!
    
    @IBOutlet weak var tweetContentsLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var inReplyLabel: UILabel!
    
    @IBOutlet weak var inReplyToTopConstraint: NSLayoutConstraint!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet{
            nameLabel.text = tweet.user?.name
            nameLabel.sizeToFit()
            if let screenName = tweet.user?.screenName {
                screenNameLabel.text = "@\(screenName)"
            }
            timeSinceLabel.text = Tweet.timeSince(tweet.timestamp!)
            
            tweetContentsLabel.text = tweet.text
            
            var displayURLs = [String]()
            if let medias = tweet.media {
                for media in medias {
                    let urlText = media["url"] as! String
                    tweetContentsLabel.text = tweetContentsLabel.text?.stringByReplacingOccurrencesOfString(urlText, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    let displayURL = media["display_url"] as! String
                    displayURLs.append(displayURL)
                }
            }
            
            if let urls = tweet.urls {
                for url in urls {
                    if let urlText = url["url"] as? String {
                        tweetContentsLabel.text = tweetContentsLabel.text?.stringByReplacingOccurrencesOfString(urlText, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    }
                    
                    if let displayURL = url["display_url"] as? String {
                        displayURLs.append(displayURL)
                    }
                }
            }
            
            if displayURLs.count > 0 {
                let content = tweetContentsLabel.text ?? ""
                let urlText = displayURLs.joinWithSeparator(" ")
                let text = NSMutableAttributedString(string: content)
                text.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14, weight: UIFontWeightRegular), range: NSRange(location: 0, length: content.characters.count))
                
                let links = NSMutableAttributedString(string: urlText)
                links.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14, weight: UIFontWeightRegular), range: NSRange(location: 0, length: urlText.characters.count))
                links.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255.0, green: 144/255.0, blue: 212/255.0, alpha: 1), range: NSRange(location: 0, length: urlText.characters.count))
                text.appendAttributedString(links)
                
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 3
                style.lineBreakMode = .ByWordWrapping
                text.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: text.string.characters.count))
                
                tweetContentsLabel.attributedText = text
            }
            
            inReplyLabel.text = nil
            inReplyLabel.sizeToFit()
            inReplyToTopConstraint.constant = 0
            
            if let userMentions = tweet.userMentions, inReplyToScreenName = tweet.inReplyToScreenName {
                for userMention in userMentions {
                    if let screenName = userMention["screen_name"] as? String {
                        if screenName == inReplyToScreenName {
                            inReplyLabel.text = "In reply to \((userMention["name"] as? String)!)"
                            inReplyLabel.sizeToFit()
                            inReplyToTopConstraint.constant = 6
                        }
                    }
                }
            }
            
            if let retweetsCount = tweet.retweetsCount {
                retweetCountLabel.text = retweetsCount > 0 ? "\(retweetsCount)" : nil
            }
            
            if let favoritesCount = tweet.favoritesCount {
                favoriteCountLabel.text = favoritesCount > 0 ? "\(favoritesCount)" : nil
            }
            
            let imageRequest = NSURLRequest(URL: (tweet.user?.profileImageURL)!)
            profileImageView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) in
                    self.profileImageView.image = image
                },
                failure: { (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) in
                    print(error)
                }
            )
            
            if tweet.retweeted! {
                retweetButton.setImage(UIImage(named: "retweet-action-on"), forState: .Normal)
            } else {
                retweetButton.setImage(UIImage(named: "retweet-action"), forState: .Normal)
            }
            
            if tweet.favorited! {
                favoriteButton.setImage(UIImage(named: "like-action-on"), forState: .Normal)
            } else {
                favoriteButton.setImage(UIImage(named: "like-action"), forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func onReply(sender: UIButton) {
        delegate?.tweetCellDidReplyToTweet!(tweet)
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
                        self.delegate?.tweetCellDidUpdateTweet!()
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
                        self.delegate?.tweetCellDidUpdateTweet!()
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
                        self.delegate?.tweetCellDidUpdateTweet!()
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
                        self.delegate?.tweetCellDidUpdateTweet!()
                    },
                    failure: { (error: NSError) -> Void in
                        print("Favorite failed \(error.localizedDescription)")
                    }
                )
            }
        }
    }
}
