//
//  RestaurantTabController.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/14/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit

class RestaurantTabController: UITabBarController {
    var owningRestaurant: ZomatoRestaraunt? {
        didSet {
            viewControllers?.forEach({
                if $0 is RestaurantDetails,
                    let vc = $0 as? RestaurantDetails {
                    vc.displayedRestaurant = owningRestaurant
                }
            })
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let title = item.title {
            switch title {
            case "Menu":
                if selectedViewController is MenuViewController,
                    let selectedVC = selectedViewController as? MenuViewController {
                    print("Doing menu")
                    selectedVC.isShowingMenu = true
                    selectedVC.isShowingEvents = false
                    
                }
            case "Events":
                if selectedViewController is MenuViewController,
                    let selectedVC = selectedViewController as? MenuViewController {
                    print("Doing events")
                    selectedVC.isShowingMenu = false
                    selectedVC.isShowingEvents = true
                    
                }
            default:()
            }
        }
    }
}


