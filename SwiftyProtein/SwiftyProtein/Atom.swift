//
//  Atom.swift
//  SwiftyProtein
//
//  Created by Сергей on 20.08.2021.
//

import Foundation

struct Point3D: Equatable, CustomStringConvertible {
	
	var x: Double
	var z: Double
	var y: Double
	
	init(x: Double, y: Double, z: Double) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	static func == (lhs: Point3D, rhs: Point3D) -> Bool {
		return lhs.x == rhs.x &&
			lhs.y == rhs.y &&
			lhs.z == rhs.z
	}
	
	var description: String {
		return "Point coordinate X:\(self.x), Y:\(self.y), Z: \(self.z)"
	}
}

struct Atom: Equatable, CustomStringConvertible {
	
	
	let name: String
	let type: String
	let formula: String
	let coordinate: Point3D
	
	init(name: String, type: String, formula: String, coordinate: Point3D) {
		self.name = name
		self.type = type
		self.formula = formula
		self.coordinate = coordinate
	}
	
	static func == (lhs: Atom, rhs: Atom) -> Bool {
		return lhs.name == rhs.name
	}
	
	var description: String {
		return "\(name) (\(type)) [\(formula)]"
	}
}
