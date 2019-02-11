//
//  ZomatoRestarauntManager.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/14/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//
/// This is an example of how I utilize delegation to return results to a calling object.
/// This also shows how I prefer to structure non-visual classes. Not the exposed method has help documentation and that all private/fileprivate methods are hidden in an extension. I prefer this to adding visibility modifiers. However, when the object is small enough, I'll use that approach.

import UIKit
import CoreLocation

protocol QueryCompleted: NSObjectProtocol {
    func updateUI()
}

class ZomatoRestarauntManager: NSObject {
    static let shared = ZomatoRestarauntManager()
    private let restEngine = ZomatoRestEngine()
    private(set) var restarauntList = [ZomatoRestaraunt]()
    private var totalNumberOfHits: Int = 0
    private var currentStart: Int = 0
    private var currentCount: Int = 20
    private var searchLocation: CLLocation?
    weak var delegate: QueryCompleted?
    
    /**
     search for restaurants near the point where the user taps the map
     
     - Author:
     Ken Cluff
     
     - returns:
     This doesn't return a value. Responses are handled through a delegate callback
     
     - parameters:
        - location: A CLLocation object. It is not optional.
     
     This accepts a CLLocation object. The app then searches for nine restaurants nearest to that location. Call back to the calling view controller is handled through a delegate.
     */
    func fetchRestarauntsNear(_ location: CLLocation) {
        searchLocation = location
        reset()
        fetchNextPage()
    }
    
    func testBuildingRestaurantsFromTestFile_DONOTUSEOTHERWISE(_ testFile: [String: Any]) {
        reset()
        buildRestarauntList(from: testFile)
    }
}

/// I prefer to group private methods needed for the class in an extension to hide them from the developer who needs to use this class for some purpose.
fileprivate extension ZomatoRestarauntManager {
    func buildRestarauntList(from json: [String: Any]) {
        extractRestaraunts(from: json)
        totalNumberOfHits = restarauntList.count
    }
    
    func fetchNextPage() {
        guard let searchLocation = searchLocation,
            currentStart <= totalNumberOfHits else { return }
        let parameterSet = getParameters(for: searchLocation)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        restEngine.searchForRestaraunts(parameterSet) { (data, response, error) in
            guard let response = response,
                let urlResponse = response as? HTTPURLResponse,
                urlResponse.statusCode == 200,
                let data = data,
                error == nil else {
                    print("There was an error: \(error?.localizedDescription ?? "Something went wrong with the query")")
                    return
            }
            
            var result: Any?
            do {
                try result = JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let results = result as? [String: Any] else { return }
                self.buildRestarauntList(from: results)
                self.delegate?.updateUI()
                
            } catch let JSONError {
                print("There was an error converting the data into JSON: \(JSONError.localizedDescription)")
            }
        }
    }
    
    func reset() {
        restarauntList.removeAll()
        totalNumberOfHits = 0
        currentStart = 0
        currentCount = 20
    }
    
    func getParameters(for location: CLLocation) -> SearchParameters {
        return SearchParameters(start: currentStart, count: currentCount, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: 10000, queryType: .get, queryTimeOut: 30)
    }
    
    func extractSummary(from json: [String: Any]) {
        var found = 0
        var start = 0
        var current = 0
        
        defer {
            totalNumberOfHits = found
            currentStart = start
            currentCount = current
        }
        guard let totalFound = json[ZomatoResources.JSONKeys.resultsFound] as? Int,
            let startValue = json[ZomatoResources.JSONKeys.resultsStart] as? Int,
            let currentValue = json[ZomatoResources.JSONKeys.resultsShown] as? Int else { return }
        
        found = totalFound
        start = startValue
        current = currentValue
    }
    
    func extractRestaraunts(from json: [String: Any]) {
        guard let restaraunts = json[ZomatoResources.JSONKeys.nearbyRestaurants] as? [[String: Any]] else { return }
        var workingList = [ZomatoRestaraunt]()
        restaraunts.forEach({
            let newRestaraunt = ZomatoRestaraunt($0)
            workingList.append(newRestaraunt)
        })
        restarauntList.append(contentsOf: workingList)
    }
}

extension ZomatoRestarauntManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalNumberOfHits
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentRestaraunt = restarauntList[indexPath.row]
        let summaryCell = tableView.dequeueReusableCell(withIdentifier: ZomatoResources.Keys.summaryCellID, for: indexPath) as! RestarauntSummaryCell
        summaryCell.owningRestaraunt = currentRestaraunt
        return summaryCell
    }
}
