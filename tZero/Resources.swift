//
//  Resources.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/15/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//
/// This is my preferred strategy for localization. Any place, not data, where a string is presented to the user is directed to this struct. This way, none of the 'NSLocalizeString' calls are in the view controllers or other objects, they are all located here. This is to facilitate maintenance of the UI strings when localization is required.
/// Note the extension at the bottom of the page to handle a tedious process used in more than one location throughout the app.

import UIKit

struct ZomatoResources {
    struct Strings {
        static let homeTitle = NSLocalizedString("Restaurant Search", comment: "")
        static let locationAnnotationTitle = NSLocalizedString("Looking Here", comment: "")
        static let howToTitle = NSLocalizedString("Instructions", comment: "")
        static let howToInstructions = NSLocalizedString("Tap on map to set location.\nThen tap search button to find restaurants.", comment: "")
        static let okCaption = NSLocalizedString("OK", comment: "")
        static let defaultNotSet = NSLocalizedString("Not set", comment: "")
        static let defaultNoneStated = NSLocalizedString("None stated", comment: "")
        static let captionCostForTwo = NSLocalizedString("Avg. Cost for Two:", comment: "")
        static let emtpyString = ""
        static let captionPriceGroup = NSLocalizedString("Price Group:", comment: "")
        static let captionVotes = NSLocalizedString("votes", comment: "")
        static let captionHere = NSLocalizedString("Here", comment: "")
        static let enumCaptionAddress = NSLocalizedString("Address", comment: "")
        static let enumCaptionRating = NSLocalizedString("User Rating", comment: "")
        static let enumCaptionCost = NSLocalizedString("Cost", comment: "")
        static let enumCaptionMap = NSLocalizedString("Map", comment: "")
        static let navigateBackButton = NSLocalizedString("Back", comment: "")
        static let navigateHomeButton = NSLocalizedString("Home", comment: "")
    }
    
    struct Keys {
        static let detailSegueID = "showRestaurantDetail"
        static let userInfoRestaurantKey = "restaurant"
        static let textCellID = "textCellID"
        static let mapCellID = "mapCellID"
        static let ratingCellID = "ratingCellID"
        static let costCellID = "costCellID"
        static let summaryCellID = "summaryCellID"
        static let pushResultsSegueID = "pushResults"
        
    }
    
    struct JSONKeys {
        static let resultsFound = "results_found"
        static let resultsStart = "results_start"
        static let resultsShown = "results_shown"
        static let nearbyRestaurants = "nearby_restaurants"
        
        struct Restaurant {
            static let restaurant = "restaurant"
            static let id = "id"
            static let name = "name"
            static let url = "url"
            static let location = "location"
            static let avgCostForTwo = "average_cost_for_two"
            static let priceRange = "price_range"
            static let rating = "user_rating"
            static let featureImage = "featured_image"
            static let photoURL = "photos_url"
            static let cuisines = "cuisines"
        }
        
        struct Location {
            static let address = "address"
            static let locality = "locality"
            static let city = "city"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let zipcode = "zipcode"
            static let countryID = "country_id"
        }
        
        struct Rating {
            static let aggregate = "aggregate_rating"
            static let text = "rating_text"
            static let color = "rating_color"
            static let votes = "votes"
            
        }
    }
    
    struct ServerKeys {
        static let zomatoAPIKey = "69d6cd060e2415ea1ddb832cca701301"
        static let geoCodeQuery = "\(ZomatoResources.ServerKeys.serverBaseURL)\(ZomatoResources.ServerKeys.apiVersion)/geocode?lat=\(ZomatoResources.ServerKeys.lookupKeyLatitude)&lon=\(ZomatoResources.ServerKeys.lookupKeyLongitude)"
        static let searchForRestarauntsInZomatoLocation = "\(ZomatoResources.ServerKeys.serverBaseURL)\(ZomatoResources.ServerKeys.apiVersion)/search?entity_type=zone&start=\(ZomatoResources.ServerKeys.lookupKeyStart)&count=\(ZomatoResources.ServerKeys.lookupKeyCount)&lat=\(ZomatoResources.ServerKeys.lookupKeyLatitude)&lon=\(ZomatoResources.ServerKeys.lookupKeyLongitude)&radius=\(ZomatoResources.ServerKeys.lookupKeyRadius)&sort=real_distance&order=asc"
        static let searchQueueString = "backgroundSearchQueue"
        static let serverBaseURL = "https://developers.zomato.com/api/"
        static let apiVersion = "v2.1"
        static let lookupKeyLatitude = "#LATITUDE#"
        static let lookupKeyLongitude = "#LONGITUDE#"
        static let lookupKeyRadius = "#RADIUS#"
        static let lookupKeyStart = "#START#"
        static let lookupKeyCount = "#COUNT#"
    }
}

extension UIViewController {
    func setBackButtonText(to text: String) {
        let backItem = UIBarButtonItem()
        backItem.title = text
        navigationItem.backBarButtonItem = backItem
    }
}
