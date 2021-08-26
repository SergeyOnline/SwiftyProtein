//
//  Network.swift
//  SwiftyProtein
//
//  Created by Сергей on 23.08.2021.
//

import Foundation

let Host = "https://data.pdbj.org/pdbjplus/data/cc/mmjson/"

func getDataFor(ligandCode code: String, complition: @escaping (LigandData?) -> ()) {
	
	guard let url = URL(string: "\(Host)\(code).json") else { return }
	let request = URLRequest(url: url)
	let session = URLSession.shared
	
	session.dataTask(with: request) { data, response, error in
		if let response: HTTPURLResponse = response as? HTTPURLResponse {
			if response.statusCode != 200 {
				print("Error: Bad status code")
				return
			}
		}
		
		guard let data = data else { return }
		guard error == nil else { return }
	
		
		var string = String(data: data, encoding: .utf8)!
		string = string.replacingOccurrences(of: "\"data_\(code)\":", with: "\n")
		string.removeFirst()
		string.removeLast()
		print(string)
		
		let newData = string.data(using: .utf8)!
		
		do {
	
			let decoder = JSONDecoder()
			let ligandData = try decoder.decode(LigandData.self, from: newData)
//			print(ligandData)
			complition(ligandData)
		} catch {
			let error = error
			print("ERROR JSON: \(error.localizedDescription)")
			complition(nil)
		}
	}.resume()
}
