//
//  Resources.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/15/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import Foundation

struct ZomatoResources {
    struct Strings {
        static let homeTitle = "Restaurant Search"
        static let locationAnnotationTitle = "Looking Here"
        static let howToTitle = "Instructions"
        static let howToInstructions = "Tap on map to set location.\nThen tap search button to find restaurants."
        static let okCaption = "OK"
        static let defaultNotSet = "Not set"
        static let defaultNoneStated = "None stated"
        static let captionCostForTwo = "Avg. Cost for Two:"
        static let emtpyString = ""
        static let captionPriceGroup = "Price Group:"
        static let captionVotes = "votes"
        static let captionHere = "Here"
    }
    
    struct Keys {
        static let detailSegueID = "showRestaurantDetail"
        static let userInfoRestaurantKey = "restaurant"
        static let textCellID = "textCellID"
        static let mapCellID = "mapCellID"
        static let ratingCellID = "ratingCellID"
        static let costCellID = "costCellID"
    }
}
