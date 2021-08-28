//
//  ListTableViewController.swift
//  SwiftyProtein
//
//  Created by Сергей on 20.08.2021.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {

	var ligands: [String] = []
	var sortedLigands: [String] = []
	private let cellId = "cellId"
	var searchBar: UISearchBar!
	var tapGestureRecognazer: UITapGestureRecognizer!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		readLigandsFromCoreData()
		
		self.navigationItem.title = "Ligands"
		
		tableView.register(ListCell.self, forCellReuseIdentifier: cellId)
		tableView.separatorColor = .black
		tableView.separatorInset = UIEdgeInsets.zero
		
		searchBar = UISearchBar()
		searchBar.placeholder = "search"
		searchBar.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//		tableView.reloadData()
		
		tapGestureRecognazer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		tapGestureRecognazer.delegate = self
		
		self.view.addGestureRecognizer(tapGestureRecognazer)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		searchBar.reloadInputViews()
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		let location = touch.location(in: tableView)
		return (tableView.indexPathForRow(at: location) == nil)
	}
	
	@objc func handleTap(sender: UITapGestureRecognizer) {
		if searchBar.isFirstResponder == true {
			searchBar.resignFirstResponder()
		}
	}

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (sortedLigands.count < 12) ? 12 : sortedLigands.count
    }
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListCell
		
		cell.textLabel?.text = (indexPath.row < sortedLigands.count) ? sortedLigands[indexPath.row] : ""
		cell.textLabel?.textColor = .black
		cell.clipsToBounds = true
		
		
//		let path = Bundle.main.path(forResource: "1", ofType: "png")!
		cell.backgroundImage.image = findBackgroundImageForCellWith(indexPath: indexPath)
        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 56
	}
	
	
	private func findBackgroundImageForCellWith(indexPath: IndexPath) -> UIImage {
		var image: UIImage
		
		let index = indexPath.row % 16
		
		let bundle = Bundle.main
		
		if index == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "0", ofType: "png")!)!
		} else if index % 15 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "15", ofType: "png")!)!
		} else if index % 14 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "14", ofType: "png")!)!
		} else if index % 13 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "13", ofType: "png")!)!
		} else if index % 12 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "12", ofType: "png")!)!
		} else if index % 11 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "11", ofType: "png")!)!
		} else if index % 10 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "10", ofType: "png")!)!
		} else if index % 9 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "9", ofType: "png")!)!
		} else if index % 8 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "8", ofType: "png")!)!
		} else if index % 7 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "7", ofType: "png")!)!
		} else if index % 6 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "6", ofType: "png")!)!
		} else if index % 5 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "5", ofType: "png")!)!
		} else if index % 4 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "4", ofType: "png")!)!
		} else if index % 3 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "3", ofType: "png")!)!
		} else if index % 2 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "2", ofType: "png")!)!
		} else if index % 1 == 0 {
			image = UIImage(contentsOfFile: bundle.path(forResource: "1", ofType: "png")!)!
		} else {
			image = UIImage(contentsOfFile: bundle.path(forResource: "0", ofType: "png")!)!
		}
		
		return image
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return searchBar
		}
		return nil
	}

	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if searchBar.isFirstResponder == true {
			searchBar.resignFirstResponder()
		}
//		super.scrollViewDidScroll(scrollView)
	}
	
	
//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if let _ = touches.first {
//			searchBar.endEditing(true)
//		}
//		super.touchesBegan(touches, with: event)
//	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row < sortedLigands.count {
			let proteinVC = ProteinViewController(ligandCode: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!)
			self.navigationController?.pushViewController(proteinVC, animated: true)
			self.tableView.deselectRow(at: indexPath, animated: true)
			if searchBar.isFirstResponder == true {
				searchBar.resignFirstResponder()
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
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
