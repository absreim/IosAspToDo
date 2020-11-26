//
//  ViewController.swift
//  AspToDo
//
//  Created by Brook Li on 11/9/20.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableData: [TodoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getDataFromApi()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action:
                                           #selector(handleRefreshControl),
                                           for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        getDataFromApi()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
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
    
    private func getDataFromApi() {
        let urlString = "https://absreimtodoapi.azurewebsites.net/api/TodoItems"
        guard let url = URL(string: urlString) else {
            fatalError("Error creating URL object when trying to GET data from API.")
        }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            guard error == nil else {
                print("Error encountered when executing data task.")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Reponse returned from HTTP request is not of type HTTPURLResponse.")
            }
            guard httpResponse.statusCode == 200 else {
                print("Unexpected status code in HTTP request:", httpResponse.statusCode)
                return
            }
            guard data != nil else {
                print("No data in response to GET request.")
                return
            }
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
                return
            }
        })
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
            fatalError("Error creating URL object when trying to GET data from API.")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = itemData
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
}
