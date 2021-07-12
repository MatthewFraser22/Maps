//
//  Extensions.swift
//  Maps
//
//  Created by Matthew on 2021-07-09.
//

import Foundation
import UIKit

/// UITableViewDelegate

extension ViewController: UITableViewDelegate {
	//what happens when you click the table view
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
		_ = tableView.cellForRow(at: indexPath)
		
		if (self.info[indexPath.row].ctype == "Route"){
			//call a function to draw a line
			drawLine(
				sourceLong: self.info[indexPath.row].orginLong!,
				sourceLat: self.info[indexPath.row].orginLat!,
				destLong: self.info[indexPath.row].destinationLong!,
				destLat: self.info[indexPath.row].destinationLat!
			)
			
		}else{
			dropPin(
				long: self.info[indexPath.row].lng,
				lat: self.info[indexPath.row].lat
			)
			
		}
	}
}

/// UITableViewDataSource

extension ViewController: UITableViewDataSource {
	
	//number of rows to show in the table
	func tableView(_ tableView: UITableView, numberOfRowsInSection Section: Int) -> Int{
		return (self.info.count)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		//displays the value name in the cell
		cell.textLabel?.text = self.info[indexPath.row].title
		return cell
	}
}
