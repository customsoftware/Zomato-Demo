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

struct ZomatoRestaraunt: Codable {
    var id: Double? // ID of the restaurant
    var name: String? // Name of the restaurant
    var url: String? // URL of the restaurant page
    var location: ResLocation? // Restaurant location details
    var averageCost: Int? // Average price of a meal for two people
    var priceRange: Int? // Price bracket of the restaurant (1 being pocket friendly and 4 being the costliest)
    var currency: String? // Local currency symbol; to be used with price
    var thumb: String? // URL of the low resolution header image of restaurant
    var featuredImage: String? // URL of the high resolution header image of restaurant
    var photosURL: String? // URL of the restaurant's photos page
    var menuURL: String? // URL of the restaurant's menu page
    var eventsURL: String? // URL of the restaurant's events page
    var userRating: UserRating? // Restaurant rating details
    var hasOnlineDelivery: Bool? // Whether the restaurant has online delivery enabled or not
    var isDeliveringNow: Bool? // Valid only if has_online_delivery = 1; whether the restaurant is accepting online orders right now
    var hasTableBooking: Bool? // Whether the restaurant has table reservation enabled or not
    var deeplink: String? // Short URL of the restaurant page; for use in apps or social
    var cuisines: String? // List of cuisines served at the restaurant in csv format
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, location, currency, thumb, deeplink, cuisines
        case averageCost = "average_cost_for_two"
        case priceRange = "price_range"
        case featuredImage = "featured_image"
        case photosURL = "photos_url"
        case menuURL = "menu_url"
        case userRating = "user_rating"
        case hasOnlineDelivery = "has_online_delivery"
        case isDeliveringNow = "is_delivering_now"
        case hasTableBooking = "has_table_booking"
    }
    
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

            self.averageCost = parameterJSON[ZomatoResources.JSONKeys.Restaurant.avgCostForTwo] as? Int
            self.priceRange = parameterJSON[ZomatoResources.JSONKeys.Restaurant.priceRange] as? Int

            if let userRatingData = parameterJSON[ZomatoResources.JSONKeys.Restaurant.rating] as? [String: Any] {
                self.userRating = UserRating(userRatingData)
            }
            self.featuredImage = parameterJSON[ZomatoResources.JSONKeys.Restaurant.featureImage] as? String
            self.photosURL = parameterJSON[ZomatoResources.JSONKeys.Restaurant.photoURL] as? String
            self.cuisines = parameterJSON[ZomatoResources.JSONKeys.Restaurant.cuisines] as? String
        }
    }
}

struct ResLocation: Codable {
    var address: String? // Complete address of the restaurant
    var locality: String? // Name of the locality
    var city: String? // Name of the city
    var latitude: Double? // Coordinates of the restaurant
    var longitude: Double? // Coordinates of the restaurant
    var zipcode: String? // Zipcode
    var countryID: Int? // ID of the country
    
    enum CodingKeys: String, CodingKey {
        case address, locality, city, latitude, longitude, zipcode
        case countryID = "country_id"
    }
    
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
        self.countryID = parameterJSON[ZomatoResources.JSONKeys.Location.countryID] as? Int
    }
}

struct UserRating: Codable {
    var aggregateRating: Double? // Restaurant rating on a scale of 0.0 to 5.0 in increments of 0.1
    var ratingText: String? // Short description of the rating
    var ratingColor: String? // Color hex code used with the rating on Zomato
    var votes: Int? // Number of ratings received
    
    enum CodingKeys: String, CodingKey {
        case votes
        case aggregateRating = "aggregate_rating"
        case ratingText = "rating_text"
        case ratingColor = "rating_color"
    }
    
    init(_ parameterJSON: [String: Any]) {
        if let aggregateRating = parameterJSON[ZomatoResources.JSONKeys.Rating.aggregate] as? String {
            self.aggregateRating = Double(aggregateRating)
        }
        self.ratingText = parameterJSON[ZomatoResources.JSONKeys.Rating.text] as? String
        self.ratingColor = parameterJSON[ZomatoResources.JSONKeys.Rating.color] as? String
        if let votes = parameterJSON[ZomatoResources.JSONKeys.Rating.votes] as? String {
            self.votes = Int(votes)
        }
    }
    
    var color: UIColor {
        var retColor = UIColor.clear
        guard let ratingColor = ratingColor else { return retColor }
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
