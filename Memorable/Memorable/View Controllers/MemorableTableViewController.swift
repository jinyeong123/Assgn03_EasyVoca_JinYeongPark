//
//  MemorableTableViewController.swift
//  Memorable
//
//
//  Created by Paige 🇰🇷 on 12/5/2023.
//

import UIKit
import os.log
import UserNotifications

class MemorableTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    var category = Category(name: "")
    var memorables: [Memorable] = []
    var memorablesInCategory: [Memorable] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredMemorables = [Memorable]()
    
    var selectedMemorable = Memorable(id: -1, head: "", body: "", category: "")
    var editingMemorable = Memorable(id: -1, head: "", body: "", category: "")
    
    // MARK: Search bar
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMemorables = memorablesInCategory.filter({( memorable : Memorable) -> Bool in
            return memorable.head.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func setSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Vocabulary"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    @IBAction func addMemorableButtonClicked(_ sender: Any) {
        // self.performSegue(withIdentifier: "AddMemorableSegue", sender: nil)
        self.performSegue(withIdentifier: "NewMemorableSegue", sender: nil)
    }
    
    @IBAction func unwindToMemorable(unwindSegue: UIStoryboardSegue) {
        guard let identifier = unwindSegue.identifier else {
            print("Cannot find unwind segue identifier")
            return
        }
        print(identifier)
        if identifier == "MemorableUnwind" {
            self.saveMemorables()
            self.setMemorableInCategory()
            self.tableView.reloadData()
        }
        if identifier == "unwindFromEditMemorable" {
            for memorable in self.memorables {
                if memorable.id == self.editingMemorable.id {
                    memorable.head = self.editingMemorable.head
                    memorable.body = self.editingMemorable.body
                }
            }
            self.saveMemorables()
            self.setMemorableInCategory()
            self.tableView.reloadData()
        }
    }
    
    private func setLabelForEmptyTable() {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)))
        label.text = "No Voca for '\(self.category.name)'\n Click add button for new voca!"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .gray
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = .none
    }
    
    private func saveMemorables() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.memorables, toFile: Memorable.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMemorables() {
        if let savedMemorables = NSKeyedUnarchiver.unarchiveObject(withFile: Memorable.ArchiveURL.path) as? [Memorable] {
            self.memorables = savedMemorables
        } else {
            os_log("Failed to laod...", log: OSLog.default, type: .error)
        }
    }
    
    private func setMemorableInCategory() {
        self.memorablesInCategory = []
        for memorable in self.memorables {
            if memorable.category == self.category.name {
                self.memorablesInCategory.append(memorable)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        self.setSearchBar()
        self.navigationItem.title = self.category.name
        self.navigationItem.rightBarButtonItems!.append(self.editButtonItem)
        self.loadMemorables()
        self.setMemorableInCategory()
    }



    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.memorablesInCategory.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        } else {
            self.setLabelForEmptyTable()
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filteredMemorables.count
        }
        if section == 0 {
            return self.memorablesInCategory.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Memorables", for: indexPath)
        
        let memorable: Memorable
        
        if isFiltering() {
            memorable = self.filteredMemorables[indexPath.row]
        } else {
            memorable = self.memorablesInCategory[indexPath.row]
        }
        
        cell.showsReorderControl = true
        cell.textLabel?.text = memorable.head
        cell.detailTextLabel?.text = memorable.body

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFiltering() {
            self.selectedMemorable = self.filteredMemorables[indexPath.row]
        } else {
            self.selectedMemorable = self.memorablesInCategory[indexPath.row]
        }
        print(self.selectedMemorable.head)
        self.performSegue(withIdentifier: "EditMemorableSegue", sender: nil)
    }
    

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedMemorables = self.memorablesInCategory.remove(at: fromIndexPath.row)
        self.memorablesInCategory.insert(movedMemorables, at: to.row)
        

        wrapper: while true {
            var find = false
            outerFor: for (index, memorable) in self.memorables.enumerated() {
                if self.category.name == memorable.category {
                    memorables.remove(at: index)
                    find = true
                    break outerFor
                }
            }
            if !find {
                break wrapper
            }
        }
        
        self.memorables += self.memorablesInCategory
        self.saveMemorables()
        self.tableView.reloadData()
    }


    func removeNotifications(memorable: Memorable) {

        var identifier: [String] = []
        identifier.append(String(memorable.id))
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifier)
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let removedMemorable = self.memorablesInCategory.remove(at: indexPath.row)
            
            var willRemoveMemorableIndex = -1
            for (index, memorable) in self.memorables.enumerated() {
                if memorable.id == removedMemorable.id {
                    willRemoveMemorableIndex = index
                }
            }
            
            if willRemoveMemorableIndex != -1 {
                self.removeNotifications(memorable: self.memorables.remove(at: willRemoveMemorableIndex))
            }
            
            self.saveMemorables()
            
            if self.memorablesInCategory.count == 0 {
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                tableView.deleteSections(indexSet as IndexSet, with: .none)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {

        }    
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }
        if identifier == "NewMemorableSegue" {
            let newMemorableTableViewController = segue.destination as! NewMemorableTableViewController
            newMemorableTableViewController.memorable = Memorable(id: -1, head: "", body: "", category: self.category.name)
            newMemorableTableViewController.memorables = self.memorables
        }
        if identifier == "EditMemorableSegue" {
            let editMemorableTableViewController = segue.destination as! EditMemorableTableViewController
            editMemorableTableViewController.memorable = self.selectedMemorable
        }
    }

}

extension MemorableTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        filterContentForSearchText(searchController.searchBar.text!)
    }
}
