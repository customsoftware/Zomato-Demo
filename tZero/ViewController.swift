//
//  ViewController.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/13/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    let searchEngine = ZomatoRestarauntManager.shared
    let locationManager = CLLocationManager()
    let segueID = "pushResults"
    var firstTouchPoint: UITouch?
    var lastPin: MKPointAnnotation?
    var mapLocationLastTouched: CLLocation? {
        didSet {
            guard let mapLocationLastTouched = mapLocationLastTouched else { return }
            navigationItem.rightBarButtonItem?.isEnabled = true
            if let _ = lastPin {
                lastPin?.coordinate = mapLocationLastTouched.coordinate
            } else {
                makePin(at: mapLocationLastTouched)
            }
        }
    }
    
    @IBAction func searchHere(_ sender: UIBarButtonItem) {
        guard let lastPin = lastPin else { return }
        let searchLocation = CLLocation(latitude: lastPin.coordinate.latitude, longitude: lastPin.coordinate.longitude)
        searchEngine.delegate = self
        searchEngine.fetchRestarauntsNear(searchLocation)
    }
    
    @IBOutlet weak var searchMap: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        showHowToAlert()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        firstTouchPoint = firstTouch
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstEndedTouch = touches.first else { return }
        if firstEndedTouch.location(in: view) == firstTouchPoint?.location(in: view) {
            let touchPoint = firstEndedTouch.location(in: searchMap)
            let location = searchMap.convert(touchPoint, toCoordinateFrom: searchMap)
            mapLocationLastTouched = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }
    }
    
    private func setupMap(for location: CLLocation) {
        searchMap.showsUserLocation = true
        searchMap.showsBuildings = true
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: localMapRegionDistance, longitudinalMeters: localMapRegionDistance)
        navigationItem.rightBarButtonItem?.isEnabled = false
        searchMap.setRegion(region, animated: true)
    }
    
    private func makePin(at location: CLLocation) {
        let locationAnnotation = MKPointAnnotation()
        locationAnnotation.title = "Looking Here"
        locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        lastPin = locationAnnotation
        searchMap.addAnnotation(locationAnnotation)
        searchMap.setCenter(locationAnnotation.coordinate, animated: true)
    }
    
    private func showHowToAlert() {
        let alert = UIAlertController(title: "Instructions", message: "Tap on map to set location.\nThen tap search button to find restaurants.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: QueryCompleted {
    func updateUI() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.segueID, sender: nil)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.setupMap(for: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Boom: \(error.localizedDescription)")
    }
}
