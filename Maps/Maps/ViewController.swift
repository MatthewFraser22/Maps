//
//  ViewController.swift
//  Maps
//
//  Created by Matt F on 2021-04-02.
//

import UIKit
import MapKit
import Foundation
//get user location
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //variables
    @IBOutlet weak var MKMap: MKMapView!
    var locationManager:CLLocationManager!
    var currentLocationStr = "Current location"
    let newPin = MKPointAnnotation()
    var info = [INFO]()
    @IBOutlet weak var locationTableView: UITableView!
    var userLong = 0.0
    var userLat = 0.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //pin to add to map
        locationTableView.delegate = self
        locationTableView.dataSource = self
        getData()
        self.MKMap.delegate = self
        
        
    }//viewDidLoad()
    
    override func viewDidAppear(_ animated: Bool) {
        
        determineCurrentLocation()
        
    }//viewDidAppear()
    
    struct INFO{
        let title: String
        let lng: Double
        let lat: Double
        let polyline: String?
        let orginLat: Double?
        let orginLong: Double?
        let destinationLat: Double?
        let destinationLong: Double?
        let ctype: String
    }//INFO
    
    //CLLocationManagerDelegate Methods
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
        
    }//locationManager()
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        
        print("Error - locationManager: \(error.localizedDescription)")
        
    }//locationManager(error)
    
    //gets the current location and uodates it
    func determineCurrentLocation(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }//determineCurrentLocation()
    
    //set a pin at the current location
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
    
    //decode JSON
    //let response= try? JSONDecoder().decode(Response.self, from: datae
    // MARK: - Response
    struct Response: Codable {
        let status: String
        let code, version: Int
        let payload: Payload?
    }

    // MARK: - Payload
    struct Payload: Codable {
        let feed: String?
        let page, totalItemCount, totalPages: Int?
        let items: [Item]?
    }

    // MARK: - Item
    struct Item: Codable {
        let id: Int?
        let title: String?
        let permalink, url: String?
        let ctype, created, modified: String?
        let createdEpoch, modifiedEpoch, privacyLevel: Int?
        let createdVia: String?
        let location: Location?
        let precis, coverImage: String?
        let displayImage: DisplayImage?
        let data: DataClass?
        let motorcycle: JSONNull?
        let source: String?
        let metaInfo: MetaInfo?
        let author: Author?
        let userMetaInfo: UserMetaInfo?
        let body: JSONNull?
        let sort: String?
    }

    // MARK: - Author
    struct Author: Codable {
        let id: Int?
        let name, realName: String?
        let avatar: Avatar?
    }

    // MARK: - Avatar
    struct Avatar: Codable {
        let list, thumb, original: String?
    }

    // MARK: - DataClass
    struct DataClass: Codable {
        let origin, destination: Destination?
        let distance, duration: Int?
        let path: JSONNull?
        let polyline: String?
    }

    // MARK: - Destination
    struct Destination: Codable {
        let lat, lng: Double?
    }

    // MARK: - DisplayImage
    struct DisplayImage: Codable {
        let title, raw, thumb, list: String?
        let original: String?
    }

    // MARK: - Location
    struct Location: Codable {
        let isDefaultLocation: Bool?
        let lastUpdated: Int?
        let lat, lng: Double?
        let geohash, country, countryCode, state: String?
        let stateCode, city, streetName, streetNumber: String?
        let postalCode, userFriendlyLocation: String?
    }

    // MARK: - MetaInfo
    struct MetaInfo: Codable {
        let upVotes, downVotes, commentCount, views: Int?
    }

    // MARK: - UserMetaInfo
    struct UserMetaInfo: Codable {
        let isAuthor, isEditable, isDeletable, isLiked: Bool?
        let isFollowingAuthor: Bool?
    }

    // MARK: - Encode/decode helpers
    class JSONNull: Codable, Hashable {

        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }

        public var hashValue: Int {
            return 0
        }

        public init() {}

        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    
    //http GET request
        private func getData() {
            
            // Create URL
            let url = URL(string: "https://engine.kissakired.com/api/v5/feed/nearby?lat=52.152803&lng=9.9417843")
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
                            
                            self.info.append(INFO(title: i.title!, lng: i.location!.lng!, lat: i.location!.lat!, polyline: i.data?.polyline, orginLat: (i.data?.origin?.lat), orginLong: (i.data?.origin?.lng), destinationLat: (i.data?.destination?.lat), destinationLong: (i.data?.destination?.lng), ctype: i.ctype!))

                        }
                        //reloads the data
                        DispatchQueue.main.async {
                            self.locationTableView.reloadData()
                        }//DispatchQueue
                        
                        
                      } catch let error {
                         print(error)
                      }//catch
                   }
               }.resume()
            
            
            }//getData()
    
    func dropPin(long: Double, lat: Double){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        MKMap.addAnnotation(annotation)
        
        //zoom in on newly added pin, zoom out of 1000
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        MKMap.setRegion(region, animated: true)
    }//dropPin()
    
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
        
    }//drawLine()
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5
        return renderer
    }//mapView()
    

}//ViewController()

extension ViewController: UITableViewDelegate{
    //what happens when you click the table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath)
        
        if (self.info[indexPath.row].ctype == "Route"){
            //call a function to draw a line
            drawLine(sourceLong: self.info[indexPath.row].orginLong!, sourceLat: self.info[indexPath.row].orginLat!, destLong: self.info[indexPath.row].destinationLong!, destLat: self.info[indexPath.row].destinationLat!)
            
        }else{
            dropPin(long: self.info[indexPath.row].lng, lat: self.info[indexPath.row].lat)
        }
        
                
    }
}//UITableViewDelegate

extension ViewController: UITableViewDataSource{
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
    
}//UITableViewDataSource

