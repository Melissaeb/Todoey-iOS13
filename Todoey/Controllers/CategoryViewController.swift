//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Melissa Elliston-Boyes on 10/12/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import Chameleon

class CategoryViewController: SwipeTableViewController {
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        
        if let navBarColour = UIColor(hexString: "1D9BF6") {
            let contrastColour = UIColor(contrastingBlackOrWhiteColorOn: navBarColour, isFlat: true)
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = navBarColour
            navBarAppearance.titleTextAttributes = [.foregroundColor: contrastColour]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColour]
            navBar.standardAppearance = navBarAppearance
            navBar.scrollEdgeAppearance = navBarAppearance
            navBar.barTintColor = navBarColour
            navBar.tintColor = contrastColour
        }
    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            guard let categoryColour = UIColor(hexString: category.color) else {fatalError()}
                    cell.backgroundColor = categoryColour
                    cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColour, isFlat: true)
        } else {
            cell.textLabel?.text = "No categories added yet"
            cell.backgroundColor = UIColor(hexString: "#1D9BF6")
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error saving category: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion.items)
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        alert.addTextField() { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
        }

        present(alert, animated: true, completion: nil)
    }
}
