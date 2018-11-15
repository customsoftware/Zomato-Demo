//
//  ZomatoRestaraunt.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/13/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit
import MapKit

let localMapRegionDistance: CLLocationDistance = 5000

enum RestaurantDisplayItems: Int, CaseIterable {
    case address
    case rating
    case cost
    case map
    
    var stringValue: String {
        var retValue = ""
        switch self {
        case .address:
            retValue = "Address"
        case .rating:
            retValue = "User Rating"
        case .cost:
            retValue = "Cost"
        case .map:
            retValue = "Map"
        }
        
        return retValue
    }
}

enum UserRatingLevels: Int, CaseIterable {
    case notRated
    case poor
    case average
    case good
    case veryGood
    case best
    
    var bracketValue: String {
        var retValue = ""
        switch self {
        case .notRated:
            retValue = "Not rated"
        case .poor:
            retValue = "Poor"
        case .average:
            retValue = "Average"
        case .good:
            retValue = "Good"
        case .veryGood:
            retValue = "Very Good"
        case .best:
            retValue = "Best"
        }
        
        return retValue
    }
}

struct ZomatoRestaraunt {
    var id: Double? // (integer, optional): ID of the restaurant ,
    var name: String? // (string, optional): Name of the restaurant ,
    var url: String? // (string, optional): URL of the restaurant page ,
    var location: ResLocation? //(ResLocation, optional): Restaurant location details ,
    var average_cost_for_two: Int? // (integer, optional): Average price of a meal for two people ,
    var price_range: Int? // (integer, optional): Price bracket of the restaurant (1 being pocket friendly and 4 being the costliest) ,
    var currency: String? // (string, optional): Local currency symbol; to be used with price ,
    var thumb: String? // (string, optional): URL of the low resolution header image of restaurant ,
    var featured_image: String? // (string, optional): URL of the high resolution header image of restaurant ,
    var photos_url: String? // (string, optional): URL of the restaurant's photos page ,
    var menu_url: String? // (string, optional): URL of the restaurant's menu page ,
    var events_url: String? // (string, optional): URL of the restaurant's events page ,
    var user_rating: UserRating? // (UserRating, optional): Restaurant rating details ,
    var has_online_delivery: Bool? // (boolean, optional): Whether the restaurant has online delivery enabled or not ,
    var is_delivering_now: Bool? // (boolean, optional): Valid only if has_online_delivery = 1; whether the restaurant is accepting online orders right now ,
    var has_table_booking: Bool? // (boolean, optional): Whether the restaurant has table reservation enabled or not ,
    var deeplink: String? // (string, optional): Short URL of the restaurant page; for use in apps or social
    var cuisines: String? // (string, optional): List of cuisines served at the restaurant in csv format ,

    var userRatingText: String {
        var retValue = UserRatingLevels.notRated
        guard let aggregateRating = user_rating?.aggregate_rating else { return retValue.bracketValue }
        if aggregateRating == 0 {
            retValue = UserRatingLevels.notRated
        } else if aggregateRating >= 4.0 {
            retValue = UserRatingLevels.veryGood
        } else if aggregateRating >= 3.5 {
            retValue = UserRatingLevels.good
        } else if aggregateRating >= 2.5 {
            retValue = UserRatingLevels.average
        } else if aggregateRating >= 1.5 {
            retValue = UserRatingLevels.poor
        }
        
        return retValue.bracketValue
    }
    
    init(_ json: [String: Any]) {
        // TODO: For a production system, all of the properties specified in the API will need to be handled.
        // For this demo, I'm just doing a subset of the properties: id, name, url, location, average price, price range, user_rating, thumb, featured image, cuisines
        if let parameterJSON = json["restaurant"] as? [String: Any] {
            if let id = parameterJSON["id"] as? String {
                self.id = Double(id)
            }
            self.name = parameterJSON["name"] as? String
            self.url = parameterJSON["url"] as? String
            
            if let locationData = parameterJSON["location"] as? [String: Any] {
                self.location = ResLocation(locationData)
            }
            
            self.average_cost_for_two = parameterJSON["average_cost_for_two"] as? Int
            self.price_range = parameterJSON["price_range"] as? Int
            
            if let userRatingData = parameterJSON["user_rating"] as? [String: Any] {
                self.user_rating = UserRating(userRatingData)
            }
            self.featured_image = parameterJSON["featured_image"] as? String
            self.photos_url = parameterJSON["photos_url"] as? String
            self.cuisines = parameterJSON["cuisines"] as? String
        }
    }
}

struct ResLocation {
    var address: String? // (string, optional): Complete address of the restaurant ,
    var locality: String? // (string, optional): Name of the locality ,
    var city: String? // (string, optional): Name of the city ,
    var latitude: Double? // (number, optional): Coordinates of the restaurant ,
    var longitude: Double? // (number, optional): Coordinates of the restaurant ,
    var zipcode: String? // (string, optional): Zipcode ,
    var country_id: Int? // (integer, optional): ID of the country
    
    init(_ parameterJSON: [String: Any]) {
        self.address = parameterJSON["address"] as? String
        self.locality = parameterJSON["locality"] as? String
        self.city = parameterJSON["city"] as? String
        if let latitude = parameterJSON["latitude"] as? String {
            self.latitude = Double(latitude)
        }
        if let longitude = parameterJSON["longitude"] as? String {
            self.longitude = Double(longitude)
        }
        self.zipcode = parameterJSON["zipcode"] as? String
        self.country_id = parameterJSON["country_id"] as? Int
    }
}

struct UserRating {
    var aggregate_rating: Double? // (number, optional): Restaurant rating on a scale of 0.0 to 5.0 in increments of 0.1 ,
    var rating_text: String? // (string, optional): Short description of the rating ,
    var rating_color: String? // (string, optional): Color hex code used with the rating on Zomato ,
    var votes: Int? // (integer, optional): Number of ratings received
    
    init(_ parameterJSON: [String: Any]) {
        if let aggregate_rating = parameterJSON["aggregate_rating"] as? String {
            self.aggregate_rating = Double(aggregate_rating)
        }
        self.rating_text = parameterJSON["rating_text"] as? String
        self.rating_color = parameterJSON["rating_color"] as? String
        if let votes = parameterJSON["votes"] as? String {
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
