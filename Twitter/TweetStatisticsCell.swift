//
//  TweetStatisticsCell.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/23/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit

class TweetStatisticsCell: UITableViewCell {
    
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            if let retweetsCount = tweet.retweetsCount {
                retweetsCountLabel.text = retweetsCount > 0 ? "\(retweetsCount)" : nil
            }
            
            if let favoritesCount = tweet.favoritesCount {
                favoritesCountLabel.text = favoritesCount > 0 ? "\(favoritesCount)" : nil
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

}
