//
//  LigandDataStructures.swift
//  SwiftyProtein
//
//  Created by Сергей on 25.08.2021.
//

struct LigandData: Decodable {
	let baseInfo: ChemComp
	let atomsInfo: ChemCompAtom
	let bondInfo: ChemCompBond
	
	private enum CodingKeys: String, CodingKey {
		case baseInfo = "chem_comp"
		case atomsInfo = "chem_comp_atom"
		case bondInfo = "chem_comp_bond"
	}
}

struct ChemCompBond: Decodable {
	let atom_id_1: [String]
	let atom_id_2: [String]
	let value_order: [String]
}

struct ChemCompAtom: Decodable {
	var xCoordinates: [Double]
	var yCoordinates: [Double]
	var zCoordinates: [Double]
	var atomId: [String]
	var symbol: [String]
	
	private enum CodingKeys: String, CodingKey {
		case xCoordinates = "pdbx_model_Cartn_x_ideal"
		case yCoordinates = "pdbx_model_Cartn_y_ideal"
		case zCoordinates = "pdbx_model_Cartn_z_ideal"
		case atomId = "atom_id"
		case symbol = "type_symbol"
	}
}

struct ChemComp: Decodable {
	let id: [String]
	let name: [String]
	let type: [String]
	let formula: [String]
}
