//
//  ViewController.swift
//  Maps
//
//  Created by Matthew Fraser on 2021-04-02.
//

import UIKit
import MapKit
import Foundation
import CoreLocation /// Get user Location

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
	
    @IBOutlet weak var MKMap: MKMapView!
	@IBOutlet weak var locationTableView: UITableView!
	
	// MARK: - Variables
	
	var info = [INFO]()
    var locationManager: CLLocationManager!
    var currentLocationStr = "Current location"
    var userLong = 0.0
    var userLat = 0.0
	
	// MARK: - Constants
	
	let newPin = MKPointAnnotation()
    
	
	/// View Did Load initialiaze stuff to load on view
	
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTableView.delegate = self /// Drop Pin on Map
        locationTableView.dataSource = self
		getData()
        self.MKMap.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }
	
	/// Description: Location manager delegate methods
	/// - Parameters:
	///   - manager: <#manager description#>
	///   - locations: <#locations description#>
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        MKMap.setRegion(mRegion, animated: true)
        
        //set user location to variables
        self.userLong = Double(mUserLocation.coordinate.longitude)
        self.userLat = Double(mUserLocation.coordinate.latitude)
        
        //drop a pin at current location
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
            mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
            mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
            MKMap.addAnnotation(mkAnnotation)
        
    }
	
    /// LocationManager(error)
	
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        
        print("Error - locationManager: \(error.localizedDescription)")
        
    }
	
	/// Gets the current location and updates it
	
    func determineCurrentLocation(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    /// set a pin at the current location
	
    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)

        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in

            if let mPlacemark = placemarks{
                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
                    if let Name = dict["Name"] as? String{
                        if let City = dict["City"] as? String{
                            self.currentLocationStr = Name + ", " + City
                        }
                    }
                }
            }
        }
        return currentLocationStr
    }
	
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
    
    func dropPin(long: Double, lat: Double){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        MKMap.addAnnotation(annotation)
        
        //zoom in on newly added pin, zoom out of 1000
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        MKMap.setRegion(region, animated: true)
    }
    
    func drawLine(sourceLong: Double, sourceLat: Double, destLong: Double, destLat: Double){
        dropPin(long: sourceLong, lat: sourceLat)
        dropPin(long: destLong, lat: destLat)
        
        let source = CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong)
        let destination = CLLocationCoordinate2D(latitude: destLat, longitude: destLong)
        
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destPlacemark = MKPlacemark(coordinate: destination)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destPlacemark)
        directionRequest.requestsAlternateRoutes = true
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [unowned self] response, error in
            
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.MKMap.addOverlay(route.polyline)
                self.MKMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5
        return renderer
    }
}



