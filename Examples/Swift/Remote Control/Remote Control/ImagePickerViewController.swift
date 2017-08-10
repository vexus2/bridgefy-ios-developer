//
//  ImagePickerViewController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class ImagePickerViewController: UIViewController {
    
    @IBOutlet weak var image1Button: UIButton!
    @IBOutlet weak var image2Button: UIButton!
    @IBOutlet weak var image3Button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageButtonPressed(_ sender: Any) {
        let selectedButton = sender as! UIButton
        
        self.image1Button.setImage(#imageLiteral(resourceName: "radioButtonOff"), for: .normal)
        self.image2Button.setImage(#imageLiteral(resourceName: "radioButtonOff"), for: .normal)
        self.image3Button.setImage(#imageLiteral(resourceName: "radioButtonOff"), for: .normal)
        
        selectedButton.setImage(#imageLiteral(resourceName: "radioButtonOn"), for: .normal)
        
        if (self.tabBarController != nil) {
            let tabBarController = self.tabBarController as! AdminViewTabBarController
            tabBarController.send(object: selectedButton.tag as Any, sender: self)
        }
    }

}
