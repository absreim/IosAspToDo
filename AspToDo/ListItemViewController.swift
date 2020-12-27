//
//  ListItemViewController.swift
//  AspToDo
//
//  Created by Brook Li on 12/25/20.
//

import UIKit

class ListItemViewController: UIViewController {
    
    var initialDescription: String = ""
    var initialId: String = ""
    var initialDone: Bool = false
    var editMode: Bool = false
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var navbar: UINavigationItem!
    
    override func viewDidLoad() {
        idTextField.text = initialId
        idTextField.isEnabled = !editMode
        descriptionTextField.text = initialDescription
        doneSwitch.isOn = initialDone
        navbar.title = editMode ? "Edit Item" : "Add Item"
    }
    
}
