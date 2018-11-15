//
// ZomatoRestaraunt.swift
// tZero
//
// Created by Kenneth Cluff on 11/13/18.
// Copyright © 2018 Kenneth Cluff. All rights reserved.
//
/// This contains an enumeration which I use to define how many rows to put in a UITableViewController when used to display a fixed number of rows. Note how the 'stringValue' of the enumeration references the ZomatoResources struct. This facilitates localization.
/// I prefer pushing logic down into the object closes to the data. Note the computed property in the UserRating object which converts the hex string passed in to the object to show the 'color' of the rating. I use this computed value so I don't have to deal with it in the view controller or tableview cell where the value is consumed.
/// The inline comments on the struct properties are used to show what the API owner specified.

import UIKit
import MapKit

let localMapRegionDistance: CLLocationDistance = 5000

enum RestaurantDisplayItems: Int, CaseIterable {
    case address
    case rating
    case cost
    case map
    
    var stringValue: String {
        var retValue = ZomatoResources.Strings.emtpyString
        switch self {
        case .address:
            retValue = ZomatoResources.Strings.enumCaptionAddress
        case .rating:
            retValue = ZomatoResources.Strings.enumCaptionRating
        case .cost:
            retValue = ZomatoResources.Strings.enumCaptionCost
        case .map:
            retValue = ZomatoResources.Strings.enumCaptionMap
        }
        
        return retValue
    }
}

struct ZomatoRestaraunt {
    var id: Double? // ID of the restaurant
    var name: String? // Name of the restaurant
    var url: String? // URL of the restaurant page
    var location: ResLocation? // Restaurant location details
    var average_cost_for_two: Int? // Average price of a meal for two people
    var price_range: Int? // Price bracket of the restaurant (1 being pocket friendly and 4 being the costliest)
    var currency: String? // Local currency symbol; to be used with price
    var thumb: String? // URL of the low resolution header image of restaurant
    var featured_image: String? // URL of the high resolution header image of restaurant
    var photos_url: String? // URL of the restaurant's photos page
    var menu_url: String? // URL of the restaurant's menu page
    var events_url: String? // URL of the restaurant's events page
    var user_rating: UserRating? // Restaurant rating details
    var has_online_delivery: Bool? // Whether the restaurant has online delivery enabled or not
    var is_delivering_now: Bool? // Valid only if has_online_delivery = 1; whether the restaurant is accepting online orders right now
    var has_table_booking: Bool? // Whether the restaurant has table reservation enabled or not
    var deeplink: String? // Short URL of the restaurant page; for use in apps or social
    var cuisines: String? // List of cuisines served at the restaurant in csv format
    
    init(_ json: [String: Any]) {
        // TODO: For a production system, all of the properties specified in the API will need to be handled.
        // For this demo, I'm just doing a subset of the properties: id, name, url, location, average price, price range, user_rating, thumb, featured image, cuisines
        if let parameterJSON = json[ZomatoResources.JSONKeys.Restaurant.restaurant] as? [String: Any] {
            if let id = parameterJSON[ZomatoResources.JSONKeys.Restaurant.id] as? String {
                self.id = Double(id)
            }
            self.name = parameterJSON[ZomatoResources.JSONKeys.Restaurant.name] as? String
            self.url = parameterJSON[ZomatoResources.JSONKeys.Restaurant.url] as? String
            
            if let locationData = parameterJSON[ZomatoResources.JSONKeys.Restaurant.location] as? [String: Any] {
                self.location = ResLocation(locationData)
            }
            
            self.average_cost_for_two = parameterJSON[ZomatoResources.JSONKeys.Restaurant.avgCostForTwo] as? Int
            self.price_range = parameterJSON[ZomatoResources.JSONKeys.Restaurant.priceRange] as? Int
            
            if let userRatingData = parameterJSON[ZomatoResources.JSONKeys.Restaurant.rating] as? [String: Any] {
                self.user_rating = UserRating(userRatingData)
            }
            self.featured_image = parameterJSON[ZomatoResources.JSONKeys.Restaurant.featureImage] as? String
            self.photos_url = parameterJSON[ZomatoResources.JSONKeys.Restaurant.photoURL] as? String
            self.cuisines = parameterJSON[ZomatoResources.JSONKeys.Restaurant.cuisines] as? String
        }
    }
}

struct ResLocation {
    var address: String? // Complete address of the restaurant
    var locality: String? // Name of the locality
    var city: String? // Name of the city
    var latitude: Double? // Coordinates of the restaurant
    var longitude: Double? // Coordinates of the restaurant
    var zipcode: String? // Zipcode
    var country_id: Int? // ID of the country
    
    init(_ parameterJSON: [String: Any]) {
        self.address = parameterJSON[ZomatoResources.JSONKeys.Location.address] as? String
        self.locality = parameterJSON[ZomatoResources.JSONKeys.Location.locality] as? String
        self.city = parameterJSON[ZomatoResources.JSONKeys.Location.city] as? String
        if let latitude = parameterJSON[ZomatoResources.JSONKeys.Location.latitude] as? String {
            self.latitude = Double(latitude)
        }
        if let longitude = parameterJSON[ZomatoResources.JSONKeys.Location.longitude] as? String {
            self.longitude = Double(longitude)
        }
        self.zipcode = parameterJSON[ZomatoResources.JSONKeys.Location.zipcode] as? String
        self.country_id = parameterJSON[ZomatoResources.JSONKeys.Location.countryID] as? Int
    }
}

struct UserRating {
    var aggregate_rating: Double? // Restaurant rating on a scale of 0.0 to 5.0 in increments of 0.1
    var rating_text: String? // Short description of the rating
    var rating_color: String? // Color hex code used with the rating on Zomato
    var votes: Int? // Number of ratings received
    
    init(_ parameterJSON: [String: Any]) {
        if let aggregate_rating = parameterJSON[ZomatoResources.JSONKeys.Rating.aggregate] as? String {
            self.aggregate_rating = Double(aggregate_rating)
        }
        self.rating_text = parameterJSON[ZomatoResources.JSONKeys.Rating.text] as? String
        self.rating_color = parameterJSON[ZomatoResources.JSONKeys.Rating.color] as? String
        if let votes = parameterJSON[ZomatoResources.JSONKeys.Rating.votes] as? String {
            self.votes = Int(votes)
        }
    }
    
    var color: UIColor {
        var retColor = UIColor.clear
        guard let ratingColor = rating_color else { return retColor }
        var cString:String = ratingColor.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            retColor = UIColor.lightGray
        } else {
            
            var rgbValue:UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            retColor = UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0))
        }
        
        return retColor
    }
}
