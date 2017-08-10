//
//  TweetTableViewCell.swift
//  TwitterForwarder
//
//  Created by Danno on 7/14/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var ownLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(tweet: Tweet) {
        self.usernameLabel.text = tweet.userId
        self.messageLabel.text = tweet.text
        self.timeLabel.text = Date(timeIntervalSince1970: tweet.time).timeAgoString(numericDates: true)
        if tweet.status == .offline {
            self.stateImage.image = #imageLiteral(resourceName: "mesh")
        } else {
            self.stateImage.image = #imageLiteral(resourceName: "internet")
        }
        if tweet.own {
            self.ownLabel.isHidden = false
            self.contentView.backgroundColor = #colorLiteral(red: 0.9441131949, green: 0.9441131949, blue: 0.9441131949, alpha: 1)
        } else {
            self.ownLabel.isHidden = true
            self.contentView.backgroundColor = UIColor.white
        }
        
    }

}
