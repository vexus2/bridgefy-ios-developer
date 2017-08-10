//
//  InitialViewController.swift
//  TicTacToe
//
//  Created by Bridgefy on 5/22/17.
//  Copyright © 2017 Bridgefy. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isEnabled = false
        nameTextField.delegate = self
        addStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addStyle() {
        //Textfield
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0.0,
                              y: nameTextField.frame.size.height - width,
                              width: nameTextField.frame.size.width,
                              height: width)
        border.borderWidth = width
        nameTextField.layer.addSublayer(border)
        nameTextField.layer.masksToBounds = true
        
        //Button
        startButton.layer.cornerRadius = 4.0
        
    }
    
    @IBAction func didChangeText(sender: UITextField) {
        
        startButton?.isEnabled = sender.text != ""
        
    }
    @IBAction func startApp(sender: UIButton) {
        
        UserDefaults.standard.setValue(nameTextField?.text, forKey: StoredValues.username)
        let username: String = nameTextField!.text!
        let userInfo: [AnyHashable : Any] = [StoredValues.username: username]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.userReady),
                                        object: self,
                                        userInfo: userInfo)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
