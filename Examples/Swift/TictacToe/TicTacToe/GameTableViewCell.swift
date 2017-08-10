//
//  GameTableViewCell.swift
//  TicTacToe
//
//  Created by Danno on 6/30/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var player1NameLabel: UILabel!
    @IBOutlet weak var player2NameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(withGame othersGame: OthersGame) {
        player1NameLabel.text = othersGame.player1Name
        player2NameLabel.text = othersGame.player2Name
    }

}
