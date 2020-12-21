//
//  TodoItemCell.swift
//  AspToDo
//
//  Created by Brook Li on 11/12/20.
//

import UIKit

class TodoItemCell: UITableViewCell {
    var itemId: String?
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemDone: TodoItemCellSwitch!
}
