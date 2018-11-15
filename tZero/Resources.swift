//
//  Resources.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/15/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

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
    }
}


extension UIViewController {
    func setBackButtonText(to text: String) {
        let backItem = UIBarButtonItem()
        backItem.title = text
        navigationItem.backBarButtonItem = backItem
    }
}
