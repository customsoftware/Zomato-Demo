//
//  MenuViewController.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/14/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit
import WebKit

class MenuViewController: UIViewController, RestaurantDetails {
    var displayedRestaurant: ZomatoRestaraunt?
    var isShowingMenu = false
    var isShowingEvents = false
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWebView()
    }
    
    private func loadWebView() {
        if let displayedRestaurant = displayedRestaurant  {
            if isShowingMenu,
                let menuURLString = displayedRestaurant.menu_url,
                let menuURL = URL(string: menuURLString) {
                let request = URLRequest(url: menuURL)
                webView.load(request)
            } else if isShowingEvents,
                let eventURLString = displayedRestaurant.events_url,
                let eventURL = URL(string: eventURLString) {
                let request = URLRequest(url: eventURL)
                webView.load(request)
            } else if let urlString = displayedRestaurant.url,
                let aURL = URL(string: urlString) {
                let request = URLRequest(url: aURL)
                webView.load(request)
            }
        }
    }
}
