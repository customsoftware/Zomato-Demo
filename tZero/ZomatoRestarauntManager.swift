//
//  ZomatoRestarauntManager.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/14/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import UIKit
import CoreLocation

protocol QueryCompleted: NSObjectProtocol {
    func updateUI()
}

class ZomatoRestarauntManager: NSObject {
    static let shared = ZomatoRestarauntManager()
    let restEngine = ZomatoRestEngine()
    private(set) var restarauntList = [ZomatoRestaraunt]()
    var totalNumberOfHits: Int = 0
    var currentStart: Int = 0
    var currentCount: Int = 20
    var searchLocation: CLLocation?
    weak var delegate: QueryCompleted?
    
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
    
    func fetchRestarauntsNear(_ location: CLLocation) {
        searchLocation = location
        reset()
        fetchNextPage()
    }
    
    func reset() {
        restarauntList.removeAll()
        totalNumberOfHits = 0
        currentStart = 0
        currentCount = 20
    }
    
    func buildRestarauntList(from json: [String: Any]) {
        extractRestaraunts(from: json)
        totalNumberOfHits = restarauntList.count
    }
    
    private func getParameters(for location: CLLocation) -> SearchParameters {
        return SearchParameters(start: currentStart, count: currentCount, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: 10000, queryType: .get, queryTimeOut: 30)
    }
    
    private func extractSummary(from json: [String: Any]) {
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
    
    private func extractRestaraunts(from json: [String: Any]) {
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
