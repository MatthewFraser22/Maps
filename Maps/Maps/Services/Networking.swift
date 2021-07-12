//
//  Networking.swift
//  Maps
//
//  Created by Matthew Fraser on 2021-07-09.
//

import Foundation
import Combine

class Networking {
	
	func getAllData() -> AnyPublisher<Response, Error> {
		guard let url = URL(string: Constants.URLs.nearbyApi) else {
			fatalError("Invalid URL")
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: Response.self, decoder: JSONDecoder())
			.receive(on: RunLoop.main)
			.eraseToAnyPublisher()
	}
}

/*
/// HTTP GET Request

func getData() {
	// Create URL
	let url = URL(string: Constants.URLs.nearbyApi)
	guard let requestUrl = url else { fatalError() }
	
	// Create URL Request
	var request = URLRequest(url: requestUrl)
	
	// Specify HTTP Method to use
	request.httpMethod = "GET"
	
	//set the HTTP request header
	request.setValue("Content-Type”: “application/json", forHTTPHeaderField: "Accept")
	
	URLSession.shared.dataTask(with: request) { data, response, error in
		// Check if Error took place
		if let error = error {
			print("Error took place \(error)")
			return
		}
		
		// Read HTTP Response Status code
		if let response = response as? HTTPURLResponse {
			print("Response HTTP Status code: \(response.statusCode)")
		}
		
		if let data = data {
			do {
				let res = try JSONDecoder().decode(Response.self, from: data)
				
				for i in res.payload?.items ?? []{

					self.info.append(
						INFO(
							title: i.title!,
							lng: i.location!.lng!,
							lat: i.location!.lat!,
							polyline: i.data?.polyline,
							orginLat: (i.data?.origin?.lat),
							orginLong: (i.data?.origin?.lng),
							destinationLat: (i.data?.destination?.lat),
							destinationLong: (i.data?.destination?.lng),
							ctype: i.ctype!)
					)
					
				}
				
				DispatchQueue.main.async {
					self.locationTableView.reloadData()
				}
				
			} catch let error {
				print(error)
			}
		}
	}.resume()

}
*/
