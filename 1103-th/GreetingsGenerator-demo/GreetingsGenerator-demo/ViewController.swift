
//
//  ViewController.swift
//  DataBindings-demo
//
//  Created by Nikolas Burk on 02/11/16.
//  Copyright © 2016 Nikolas Burk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var greetingsTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet var greetingButtons: [UIButton]!
    
    var indexSelectedButton = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        greetingsTextField.addTarget(self, action: #selector(ViewController.changeLabel), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(ViewController.changeLabel), for: .editingChanged)
        stateChanged(stateSegmentedControl)
        
        for i in 0..<greetingButtons.count{
            greetingButtons[i].tag = i
        }
        greetingsButtonPressed(greetingButtons[0])
        
    }
    
    
    func changeLabel(){
        switch stateSegmentedControl.selectedSegmentIndex {
        case 0: //Use buttons state
            greetingsLabel.text = "\(greetingButtons[indexSelectedButton].titleLabel!.text!) \(nameTextField.text!)"
        case 1: //Use textfield state
            greetingsLabel.text = "\(greetingsTextField.text!) \(nameTextField.text!)"
        default:
            print("new state")
        }
        
    }
    
    @IBAction func stateChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //Use buttons state
            self.greetingsTextField.isEnabled = false
            for button in greetingButtons{
                button.isEnabled = true
            }
        case 1: //Use textfield state
            self.greetingsTextField.isEnabled = true
            for button in greetingButtons{
                button.isEnabled = false
            }
            
        default:
            print("new state")
        }
        changeLabel()
    }
    
    @IBAction func greetingsButtonPressed(_ sender: UIButton) {
        if stateSegmentedControl.selectedSegmentIndex == 0 {
            for button in greetingButtons{
                button.backgroundColor = UIColor.clear
                button.titleLabel?.textColor = UIColor.black
            }
            
            indexSelectedButton = sender.tag
            sender.backgroundColor = UIColor.blue
            sender.titleLabel?.textColor = UIColor.white
            changeLabel()
        }
    }
    
}
