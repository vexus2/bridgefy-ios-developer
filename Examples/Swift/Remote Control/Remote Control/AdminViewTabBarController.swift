//
//  AdminViewTabBarController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class AdminViewTabBarController: UITabBarController {
    
    public var mvc: MainViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Admin panel"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func send(object: Any?, sender: Any) {
        if (self.mvc != nil) {
            self.mvc!.send(object: object, sender: sender);
        }
    }
    
}
