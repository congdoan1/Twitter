//
//  TweetDetailsCell.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/23/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit

class TweetDetailsCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetContentsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var inReplyToLabel: UILabel!
    @IBOutlet weak var inReplyToTopConstraint: NSLayoutConstraint!
    
    var tweet: Tweet! {
        didSet {
            nameLabel.text = tweet.user?.name
            nameLabel.sizeToFit()
            
            if let screenName = tweet.user?.screenName {
               screenNameLabel.text = "@\(screenName)"
            } else {
                screenNameLabel.text = nil
            }
            
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
                    let urlText = url["url"] as! String
                    tweetContentsLabel.text = tweetContentsLabel.text?.stringByReplacingOccurrencesOfString(urlText, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    let displayURL = url["display_url"] as! String
                    displayURLs.append(displayURL)
                }
            }
            
            if displayURLs.count > 0 {
                let content = tweetContentsLabel.text ?? ""
                let urlText = "" + displayURLs.joinWithSeparator(" ")
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
            
            inReplyToLabel.text = nil
            inReplyToLabel.sizeToFit()
            inReplyToTopConstraint.constant = 0
            
            if let userMentions = tweet.userMentions, inReplyToScreenName = tweet.inReplyToScreenName {
                for userMention in userMentions {
                    if let screenName = userMention["screen_name"] as? String {
                        if screenName == inReplyToScreenName {
                            inReplyToLabel.text = "In reply to \((userMention["name"] as? String)!)"
                            inReplyToLabel.sizeToFit()
                            inReplyToTopConstraint.constant = 6
                        }
                    }
                }
            }
            
            if let profileImageURL = tweet.user?.profileImageURL {
                profileImageView.setImageWithURL(profileImageURL)
            }
            
            if let timestamp = tweet.timestamp {
                let formater = NSDateFormatter()
                formater.dateFormat = "M/d/yy, HH:mm"
                timeLabel.text = formater.stringFromDate(timestamp)
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

}
