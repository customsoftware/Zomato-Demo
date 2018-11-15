//
//  tZeroTests.swift
//  tZeroTests
//
//  Created by Kenneth Cluff on 11/13/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import XCTest
@testable import tZero

let referenceQueryString = "https://developers.zomato.com/api/v2.1/search?entity_type=zone&start=21&count=40&lat=40.769&lon=-111.889&radius=1000&sort=real_distance&order=asc"
let geoCodeQueryString = "https://developers.zomato.com/api/v2.1/geocode?lat=40.769&lon=-111.889"

class tZeroTests: XCTestCase {

    let engine = ZomatoRestEngine()
    let restarauntEngine = ZomatoRestarauntManager()
    let testParameters = SearchParameters(start: 21, count: 40, latitude: 40.769, longitude: -111.889, radius: 1000, queryType: RestCallType.get, queryTimeOut: 30)
    
    func testQueryBuilding() {
        let testString = engine.buildQueryString(using: testParameters)
        XCTAssert(testString == referenceQueryString, "The two query strings should be identical. They are not.\n Test String:\(referenceQueryString) \nGenerated String: \(testString)")
    }

    func testZomatoQuery() {
        let expectation = XCTestExpectation(description: "Testing query of Zomato search API")
        
        engine.searchForRestaraunts(testParameters) { (data, response, error) in
            defer { expectation.fulfill() }
            guard let response = response,
                let urlResponse = response as? HTTPURLResponse,
                error == nil else {
                    XCTAssert(false, "The query failed for some reason. \(error?.localizedDescription ?? "General failure")")
                    return
            }
            XCTAssert(urlResponse.statusCode == 200 , "We got back a status code other than 200. We got back \(urlResponse.statusCode)")
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testBuildRestarauntUserReviewDetails() {
        let bundle = Bundle(for: type(of: self))
        let testURLString = "file:///\(bundle.path(forResource: "TestResults", ofType: "json")!)"
        let testURL = URL(string: testURLString)
        var localRestarauntResults: [String: Any]?
        do {
            try localRestarauntResults = convert(Data(contentsOf: testURL!))
            guard let localRestarauntResults = localRestarauntResults else {
                XCTAssert(false, "Could not read test file")
                return
            }
            restarauntEngine.reset()
            restarauntEngine.buildRestarauntList(from: localRestarauntResults)
            guard let first = restarauntEngine.restarauntList.first,
                let firstRating = first.user_rating else {
                    XCTAssert(false, "Couldn't get restaurant from list")
                    return
            }
            
            XCTAssert(firstRating.aggregate_rating ?? 0 == 4.5, "Got the wrong average rating for the restaurant")
            XCTAssert(firstRating.rating_text ?? "" == "Excellent", "Got the wrong rating level for the restaurant")
            XCTAssert(firstRating.votes ?? -1 == 646, "Got the wrong number of votes for the restaurant")
            
        } catch let error {
            XCTAssert(false, "Reading test file failed: \(error.localizedDescription)")
        }
    }
    
    func testBuildRestarauntLocationDetails() {
        let bundle = Bundle(for: type(of: self))
        let testURLString = "file:///\(bundle.path(forResource: "TestResults", ofType: "json")!)"
        let testURL = URL(string: testURLString)
        var localRestarauntResults: [String: Any]?
        do {
            try localRestarauntResults = convert(Data(contentsOf: testURL!))
            guard let localRestarauntResults = localRestarauntResults else {
                XCTAssert(false, "Could not read test file")
                return
            }
            restarauntEngine.reset()
            restarauntEngine.buildRestarauntList(from: localRestarauntResults)
            guard let first = restarauntEngine.restarauntList.first,
                let firstLocation = first.location else {
                XCTAssert(false, "Couldn't get restaruant from list")
                return
            }
            
            XCTAssert(firstLocation.address ?? "None" == "111 E Broadway Ste 170, Salt Lake City 84111", "Got the wrong address for the restaurant")
            XCTAssert(firstLocation.latitude ?? 0 == 40.763044, "Got the wrong latitude for the restaurant")
            XCTAssert(firstLocation.longitude ?? 0 == -111.887773, "Got the wrong longitude for the restaurant")
            XCTAssert(firstLocation.country_id ?? -1 == 216, "Got the wrong country ID for the restaurant")
            
        } catch let error {
            XCTAssert(false, "Reading test file failed: \(error.localizedDescription)")
        }
    }
    
    func testBuildRestarauntDetails() {
        let bundle = Bundle(for: type(of: self))
        let testURLString = "file:///\(bundle.path(forResource: "TestResults", ofType: "json")!)"
        let testURL = URL(string: testURLString)
        var localRestarauntResults: [String: Any]?
        do {
            try localRestarauntResults = convert(Data(contentsOf: testURL!))
            guard let localRestarauntResults = localRestarauntResults else {
                XCTAssert(false, "Could not read test file")
                return
            }
            restarauntEngine.reset()
            restarauntEngine.buildRestarauntList(from: localRestarauntResults)
            guard let first = restarauntEngine.restarauntList.first else {
                XCTAssert(false, "Couldn't get restaruant from list")
                return
            }
            
            XCTAssert(first.name ?? "None" == "The Copper Onion", "Got the wrong name for the restaurant")
            XCTAssert(first.cuisines ?? "None" == "Breakfast, European", "Got the wrong cuisine for the restaurant")
            XCTAssert(first.price_range ?? -1 == 3, "Got the wrong price range for the restaurant")
            XCTAssert(first.average_cost_for_two ?? -1 == 40, "Got the wrong average price for two for the restaurant")
            
        } catch let error {
            XCTAssert(false, "Reading test file failed: \(error.localizedDescription)")
        }
    }
    
    func testZomatoQueryString() {
        let expectation = XCTestExpectation(description: "Testing query of Zomato search API")
        let bundle = Bundle(for: type(of: self))
        let testURLString = "file:///\(bundle.path(forResource: "TestResults", ofType: "json")!)"
        let testURL = URL(string: testURLString)
        
        engine.searchForRestaraunts(testParameters) { (data, response, error) in
            defer { expectation.fulfill() }
            guard let data = data,
                let testStringURL = testURL,
                error == nil else {
                    XCTAssert(false, "The query failed for some reason. \(error?.localizedDescription ?? "General failure")")
                    return
            }
            
            var testData: Data?
            do {
                try testData = Data(contentsOf: testStringURL)
                guard let jsonDictionary = try self.convert(data),
                    let localDictionary = try self.convert(testData!) else { return }
                
                XCTAssert(jsonDictionary.count == localDictionary.count, "Should contain the same data")
                
            } catch let error {
                XCTAssert(false, "Reading test file failed: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    private func convert(_ data: Data) throws -> [String: Any]? {
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments
            ) as? [String: Any]
    }
}

