//
//  ListTableViewController.swift
//  SwiftyProtein
//
//  Created by Сергей on 20.08.2021.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController, UISearchBarDelegate {

	var ligands: [String] = []
	var sortedLigands: [String] = []
	private let cellId = "cellId"
	var searchBar: UISearchBar!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		readLigandsFromCoreData()
		
		self.navigationItem.title = "Ligands"
		
		tableView.register(ListCell.self, forCellReuseIdentifier: cellId)
		
		searchBar = UISearchBar()
		searchBar.placeholder = "search"
		searchBar.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//		tableView.reloadData()
    }

    // MARK: - Table view data source

	/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
	*/
	
	//https://pdbj.org/rest/newweb/fetch/file?cat=cc&format=mdl&id=ABA

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sortedLigands.count
    }
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
		
		cell.textLabel?.text = sortedLigands[indexPath.row]
        return cell
    }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return searchBar
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let proteinVC = ProteinViewController(ligandCode: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!)
		self.navigationController?.pushViewController(proteinVC, animated: true)
	}
	
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: - SearchBarDelegate
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
	
		if searchText.isEmpty {
			sortedLigands = ligands
			tableView.reloadData()
			return
		}
		
		var text = searchText
		text.removeAll { character in
			return character == " "
		}
		
		sortedLigands = ligands.filter({ str in
			str.hasPrefix(text.uppercased())
		})
		
		if sortedLigands.isEmpty {
			let alertVC = UIAlertController(title: "", message: "Ligand not found", preferredStyle: .alert)
			let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
			alertVC.addAction(action)
			self.present(alertVC, animated: true, completion: nil)
			searchBar.text = ""
			sortedLigands = ligands
		} else {
			sortedLigands.sort()
		}
		
		tableView.reloadData()
	}
	
	func readLigandsFromCoreData() {
		guard let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer else { fatalError("This view needs a persistent container.") }
		let context = container.viewContext
		let request: NSFetchRequest<Ligand> = Ligand.fetchRequest()
		do {
			let array = try context.fetch(request)
			ligands = array.map({ $0.name!})
			sortedLigands = ligands
		} catch {
			let error = error as NSError
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
	}

}
