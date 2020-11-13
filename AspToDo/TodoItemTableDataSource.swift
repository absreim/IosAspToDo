//
//  TodoItemTableDataSource.swift
//  AspToDo
//
//  Created by Brook Li on 11/12/20.
//

import UIKit

class TodoItemTableDataSource: NSObject, UITableViewDataSource {
    
    let sampleData = [
        TodoItem(description: "Learn iOS development", isDone: false),
        TodoItem(description: "Book travel", isDone: true),
        TodoItem(description: "Clean room", isDone: false)
    ]
    
    // Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }

    // Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! TodoItemCell
       
        // Configure the cell’s contents.
        cell.itemDescription!.text = sampleData[indexPath.row].description
        cell.itemDone!.isOn = sampleData[indexPath.row].isDone
           
        return cell
    }
}
