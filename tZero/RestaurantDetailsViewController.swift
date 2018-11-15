//
//  RestaurantDetailsViewController.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/14/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailsViewController: UITableViewController {
    
    var displayedRestaurant: ZomatoRestaraunt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = displayedRestaurant?.name ?? ZomatoResources.Strings.emtpyString
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return RestaurantDisplayItems.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var retCell: UITableViewCell?
        let rowKey = RestaurantDisplayItems.allCases[indexPath.row]
        switch rowKey {
        case .address:
            let textCell = tableView.dequeueReusableCell(withIdentifier: ZomatoResources.Keys.textCellID, for: indexPath) as? TextCell
            textCell?.configure(rowKey, displayedRestaurant)
            retCell = textCell
            
        case .map:
            let mapCell = tableView.dequeueReusableCell(withIdentifier: ZomatoResources.Keys.mapCellID, for: indexPath) as? MapCell
            mapCell?.configure(rowKey, displayedRestaurant)
            retCell = mapCell
            
        case .cost:
            let costCell = tableView.dequeueReusableCell(withIdentifier: ZomatoResources.Keys.costCellID, for: indexPath) as? CostCell
            costCell?.configure(rowKey, displayedRestaurant)
            retCell = costCell
            
        case .rating:
            let ratingCell = tableView.dequeueReusableCell(withIdentifier: ZomatoResources.Keys.ratingCellID, for: indexPath) as? RatingCell
            ratingCell?.configure(rowKey, displayedRestaurant)
            retCell = ratingCell
        }
        
        return retCell!
    }
}

// MARK: - Cell definitions
class TextCell: UITableViewCell {
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var content: UILabel!
    
    func configure(_ key: RestaurantDisplayItems, _ content: ZomatoRestaraunt?) {
        caption.text = key.stringValue
        self.content.text = content?.location?.address ?? ZomatoResources.Strings.emtpyString
    }
}

class CostCell: UITableViewCell {
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var costForTwo: UILabel!
    @IBOutlet weak var priceCategory: UILabel!
    
    func configure(_ key: RestaurantDisplayItems, _ content: ZomatoRestaraunt?) {
        caption.text = key.stringValue
        if let cost4Two = content?.average_cost_for_two {
            costForTwo.text = "\(ZomatoResources.Strings.captionCostForTwo) \(cost4Two)"
        } else {
            costForTwo.text = ZomatoResources.Strings.emtpyString
        }
        priceCategory.text = "\(ZomatoResources.Strings.captionPriceGroup) \(content?.price_range ?? 0)"
    }
}


class RatingCell: UITableViewCell {
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    
    func configure(_ key: RestaurantDisplayItems, _ content: ZomatoRestaraunt?) {
        caption.text = key.stringValue
        let ratingString = "\(content?.user_rating?.rating_text ?? ZomatoResources.Strings.emtpyString) - \(content?.user_rating?.votes ?? 0) \(ZomatoResources.Strings.captionVotes)"
        
        ratingLabel.text = ratingString
        if let content = content,
            let rating = content.user_rating?.aggregate_rating {
            ratingButton.setTitle("\(rating)", for: .normal)
            ratingButton.layer.backgroundColor = content.user_rating?.color.cgColor
            ratingButton.layer.cornerRadius = ratingButton.frame.height/2
            ratingButton.layer.borderColor = UIColor.black.cgColor
            ratingButton.layer.borderWidth = 1.03
        }
    }
}

class MapCell: UITableViewCell {
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cMapViewHeight: NSLayoutConstraint!
    
    func configure(_ key: RestaurantDisplayItems, _ content: ZomatoRestaraunt?) {
        caption.text = key.stringValue
        if let content = content {
            setUpMap(for: content)
        }
        
        if let view = UIApplication.shared.windows.first,
            view.frame.height > 568 {
            cMapViewHeight.constant = 600
        }
    }
    
    private func setUpMap(for restaurant: ZomatoRestaraunt) {
        if let location = restaurant.location,
            let latitude = location.latitude,
            let longitude = location.longitude {
            let restaurantAnnotation = MKPointAnnotation()
            restaurantAnnotation.title = restaurant.name ?? ZomatoResources.Strings.captionHere
            restaurantAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.showsUserLocation = true
            mapView.addAnnotation(restaurantAnnotation)
            mapView.setCenter(restaurantAnnotation.coordinate, animated: true)
            mapView.showsBuildings = true
            let region = MKCoordinateRegion(center: restaurantAnnotation.coordinate, latitudinalMeters: localMapRegionDistance, longitudinalMeters: localMapRegionDistance)
            mapView.setRegion(region, animated: true)
        }
    }
}
