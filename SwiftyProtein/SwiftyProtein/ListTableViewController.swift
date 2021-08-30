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
		
		self.navigationItem.title = NSLocalizedString("ligands", comment: "")
		
		tableView.register(ListCell.self, forCellReuseIdentifier: cellId)
		tableView.separatorColor = .black
		tableView.separatorInset = UIEdgeInsets.zero
		
		searchBar = UISearchBar()
		searchBar.placeholder = NSLocalizedString("search", comment: "")
		searchBar.delegate = self

//		tableView.reloadData()
		
		tapGestureRecognazer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		tapGestureRecognazer.delegate = self
		
		self.view.addGestureRecognizer(tapGestureRecognazer)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		searchBar.reloadInputViews()
	}
	
	//MARK: - Handle Gesture Recognizer
	
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
		return (sortedLigands.count < 13) ? 13 : sortedLigands.count
    }
	
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListCell
		
		cell.textLabel?.text = (indexPath.row < sortedLigands.count) ? sortedLigands[indexPath.row] : ""
		cell.selectionStyle = (indexPath.row < sortedLigands.count) ? .default : .none
		cell.textLabel?.textColor = .black
		cell.clipsToBounds = true
		cell.backgroundImage.image = findBackgroundImageForCellWith(indexPath: indexPath)
        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 56
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return searchBar
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row < sortedLigands.count {
			let proteinVC = ProteinViewController(ligandCode: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!)
			self.navigationController?.pushViewController(proteinVC, animated: true)
			self.tableView.deselectRow(at: indexPath, animated: true)
		}
		if searchBar.isFirstResponder == true {
			searchBar.resignFirstResponder()
		}
	}
	
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
			let alertVC = UIAlertController(title: "", message: NSLocalizedString("errorNotFoundLigand", comment: ""), preferredStyle: .alert)
			let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
			alertVC.addAction(action)
			self.present(alertVC, animated: true, completion: nil)
			searchBar.text = ""
			sortedLigands = ligands
		} else {
			sortedLigands.sort()
		}
		
		tableView.reloadData()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	//MARK: Scroll View Methods
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if searchBar.isFirstResponder == true {
			searchBar.resignFirstResponder()
		}
//		super.scrollViewDidScroll(scrollView)
	}
	
	//MARK: - Private Functions
	
	private func readLigandsFromCoreData() {
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
	
	private func findBackgroundImageForCellWith(indexPath: IndexPath) -> UIImage {
		var image: UIImage
		
		let index = indexPath.row % 16
		
		let bundle = Bundle.main
		
		switch index {
		case 15:
			image = UIImage(contentsOfFile: bundle.path(forResource: "15", ofType: "png")!)!
		case 14:
			image = UIImage(contentsOfFile: bundle.path(forResource: "14", ofType: "png")!)!
		case 13:
			image = UIImage(contentsOfFile: bundle.path(forResource: "13", ofType: "png")!)!
		case 12:
			image = UIImage(contentsOfFile: bundle.path(forResource: "12", ofType: "png")!)!
		case 11:
			image = UIImage(contentsOfFile: bundle.path(forResource: "11", ofType: "png")!)!
		case 10:
			image = UIImage(contentsOfFile: bundle.path(forResource: "10", ofType: "png")!)!
		case 9:
			image = UIImage(contentsOfFile: bundle.path(forResource: "9", ofType: "png")!)!
		case 8:
			image = UIImage(contentsOfFile: bundle.path(forResource: "8", ofType: "png")!)!
		case 7:
			image = UIImage(contentsOfFile: bundle.path(forResource: "7", ofType: "png")!)!
		case 6:
			image = UIImage(contentsOfFile: bundle.path(forResource: "6", ofType: "png")!)!
		case 5:
			image = UIImage(contentsOfFile: bundle.path(forResource: "5", ofType: "png")!)!
		case 4:
			image = UIImage(contentsOfFile: bundle.path(forResource: "4", ofType: "png")!)!
		case 3:
			image = UIImage(contentsOfFile: bundle.path(forResource: "3", ofType: "png")!)!
		case 2:
			image = UIImage(contentsOfFile: bundle.path(forResource: "2", ofType: "png")!)!
		case 1:
			image = UIImage(contentsOfFile: bundle.path(forResource: "1", ofType: "png")!)!
		default:
			image = UIImage(contentsOfFile: bundle.path(forResource: "0", ofType: "png")!)!
		}
		
		return image
	}

}
