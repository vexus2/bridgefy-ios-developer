//
//  PlayerTableViewCell.swift
//  TicTacToe
//
//  Created by Bridgefy on 5/29/17.
//  Copyright © 2017 Bridgefy. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        indicator.layer.cornerRadius = 11.0
    }

    
    func configure(withPlayer player: Player) {
        playerNameLabel.text = player.userName
        if player.playerStatus == .Available {
            statusLabel.text = "Available"
            indicator.backgroundColor = UIColor.green
        } else {
            statusLabel.text = "Busy"
            indicator.backgroundColor = UIColor.red
        }
    }

}
