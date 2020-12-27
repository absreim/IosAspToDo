//
//  ViewController.swift
//  AspToDo
//
//  Created by Brook Li on 11/9/20.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableData: [TodoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = editButtonItem
        getDataFromApi()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action:
                                           #selector(handleRefreshControl),
                                           for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editListItem" {
            let listItemNavController = segue.destination as! UINavigationController
            let listItemViewController = listItemNavController.viewControllers.first as! ListItemViewController
            let todoListItem = sender as! TodoItem
            listItemViewController.initialId = todoListItem.id
            listItemViewController.initialDescription = todoListItem.name
            listItemViewController.initialDone = todoListItem.isComplete
            listItemViewController.editMode = true
        }
    }
    
    @objc func handleRefreshControl() {
        getDataFromApi()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
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
        let dataRow = tableData[indexPath.row]
        cell.itemDescription!.text = dataRow.name
        cell.itemDone!.isOn = dataRow.isComplete
        cell.itemDone!.itemId = dataRow.id
        cell.itemId = dataRow.id
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let itemId = tableData[indexPath.row].id
        
        tableData.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        let urlString = "https://absreimtodoapi.azurewebsites.net/api/TodoItems/\(itemId)"
        guard let url = URL(string: urlString) else {
            fatalError("Error creating URL object when trying to GET data from API.")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    // MARK: UITableViewDelegate functions
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "editListItem", sender: tableData[indexPath.row])
    }
    
    // MARK: Network utility functions
    
    private func getDataFromApi() {
        let urlString = "https://absreimtodoapi.azurewebsites.net/api/TodoItems"
        guard let url = URL(string: urlString) else {
            fatalError("Error creating URL object when trying to GET data from API.")
        }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Reponse returned from HTTP request is not of type HTTPURLResponse.")
            }
            if error != nil {
                print("Error encountered when executing data task.")
            }
            else if httpResponse.statusCode != 200 {
                print("Unexpected status code in HTTP request:", httpResponse.statusCode)
            }
            else if data == nil {
                print("No data in response to GET request.")
            }
            else {
                let decoder = JSONDecoder()
                do {
                    let newTableData = try decoder.decode([TodoItem].self, from: data!)
                    self.tableData = newTableData
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch {
                    print("Failed to decode data from API.")
                }
            }
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        })
        task.resume()
    }
    
    private func postItem(item: TodoItem) {
        let encoder = JSONEncoder()
        var itemData: Data?
        do {
            itemData = try encoder.encode(item)
        }
        catch {
            print("Failed to encode data to post.")
            return
        }
        
        let urlString = "https://absreimtodoapi.azurewebsites.net/api/TodoItems"
        guard let url = URL(string: urlString) else {
            fatalError("Error creating URL object when trying to POST data to API.")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = itemData
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    // MARK: Actions
    
    @IBAction func switchValueChanged(_ sender: TodoItemCellSwitch) {
        let id = sender.itemId!
        let value = sender.isOn
        
        var foundItem: TodoItem? = nil
        for item in tableData {
            if id == item.id {
                foundItem = item
                break
            }
        }
        guard foundItem != nil else {
            print("Could not find item with id \(id).")
            return
        }
        let newItem = TodoItem(id: id, name: foundItem!.name, isComplete: value)
        let encoder = JSONEncoder()
        var itemData: Data?
        do {
            itemData = try encoder.encode(newItem)
        }
        catch {
            print("Failed to encode data from table.")
            return
        }
        
        let urlString = "https://absreimtodoapi.azurewebsites.net/api/TodoItems/\(id)"
        guard let url = URL(string: urlString) else {
            fatalError("Error creating URL object when trying to PUT data to API.")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = itemData
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    // MARK: Segues
    
    @IBAction func cancelUnwindAction(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func saveUnwindAction(unwindSegue: UIStoryboardSegue) {
        let listItemModal = unwindSegue.source as! ListItemViewController
        let newItemId = listItemModal.idTextField.text!
        let newItemDescription = listItemModal.descriptionTextField.text!
        let newItemDone = listItemModal.doneSwitch.isOn
        let newTodoItem = TodoItem(id: newItemId, name: newItemDescription, isComplete: newItemDone)
        tableData.append(newTodoItem)
        tableView.reloadData() // TODO: Try to visually insert the cell instead of reloading the table
        postItem(item: newTodoItem)
    }
}
