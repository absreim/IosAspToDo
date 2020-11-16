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
        cell.itemDescription!.text = tableData[indexPath.row].name
        cell.itemDone!.isOn = tableData[indexPath.row].isComplete
           
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
                fatalError("Error encountered while making HTTP request.")
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Reponse returned from HTTP request is not of type HTTPURLResponse.")
            }
            guard httpResponse.statusCode == 200 else {
                fatalError("Unexpected status code in reponse to GET request.")
            }
            guard data != nil else {
                fatalError("No data in response to GET request.")
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
                fatalError("Failed to decode data from API.")
            }
        })
        task.resume()
    }
}
