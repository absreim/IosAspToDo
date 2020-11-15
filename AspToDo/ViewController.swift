//
//  ViewController.swift
//  AspToDo
//
//  Created by Brook Li on 11/9/20.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableData = [
        TodoItem(description: "Learn iOS development", isDone: false),
        TodoItem(description: "Book travel", isDone: true),
        TodoItem(description: "Clean room", isDone: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    // Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! TodoItemCell
       
        // Configure the cell’s contents.
        cell.itemDescription!.text = tableData[indexPath.row].description
        cell.itemDone!.isOn = tableData[indexPath.row].isDone
           
        return cell
    }
    
}
