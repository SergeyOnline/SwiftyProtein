//
//  Atom.swift
//  SwiftyProtein
//
//  Created by Сергей on 20.08.2021.
//

import Foundation


struct Atoms: Decodable {
	
	var ordinal: [Int]
	var symbol: [String]
	var name_en: [String]
	var name_ru: [String]
	var name_la: [String]
	var atomic_mass: [Double]
	var levels: [[Int]]
	var series: [String]

	
	func valueForPropertyName(name: String) -> [String] {
		switch name {
		case "name_en": return self.name_en
		case "name_ru": return self.name_ru
		case "name_la": return self.name_la
		default: fatalError("Wrong property name")
		}
	}
}
