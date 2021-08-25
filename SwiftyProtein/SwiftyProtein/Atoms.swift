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
	var atomic_mass: [Double]
	var levels: [[Int]]
	var series: [String]

}
