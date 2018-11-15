//
//  RestEngine.swift
//  tZero
//
//  Created by Kenneth Cluff on 11/13/18.
//  Copyright © 2018 Kenneth Cluff. All rights reserved.
//

import Foundation

typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

enum QueryErrors: Error {
    case invalidQueryString
}

enum RestCallType: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

struct SearchParameters {
    var start: Int
    var count: Int
    var latitude: Double
    var longitude: Double
    var radius: Int
    var queryType: RestCallType
    var queryTimeOut: TimeInterval
}

class ZomatoRestEngine: NSObject {
    private var dataTask: URLSessionDataTask?
    private let dataSession = URLSession(configuration: .default)
    
    func searchForRestaraunts(_ searchParameters: SearchParameters, with callBack: @escaping CompletionHandler) {
        dataTask?.cancel()
        
        let queryString = buildGeoCodeQuery(using: searchParameters)
//        let queryString = buildQueryString(using: searchParameters)
        guard let url = URL(string: queryString) else { return }
        let request = buildURLRequest(url, using: searchParameters)
        
        dataTask = dataSession.dataTask(with: request) { (data, response, error) in
            callBack(data, response, error)
        }
        dataTask?.resume()
    }
    
}

extension ZomatoRestEngine {
    func getJSONStringFrom(_ data: Data) -> String? {
        return String(data: data, encoding: .utf8)
    }
    
    func buildGeoCodeQuery(using parameters: SearchParameters) -> String {
        var retValue = ZomatoResources.ServerKeys.geoCodeQuery
        retValue = retValue.replacingOccurrences(of: ZomatoResources.ServerKeys.lookupKeyLatitude, with: "\(parameters.latitude)")
        retValue = retValue.replacingOccurrences(of: ZomatoResources.ServerKeys.lookupKeyLongitude, with: "\(parameters.longitude)")
        return retValue
    }
    
    func buildQueryString(using parameters: SearchParameters) -> String {
        var retValue = ZomatoResources.ServerKeys.searchForRestarauntsInZomatoLocation
        retValue = retValue.replacingOccurrences(of: ZomatoResources.ServerKeys.lookupKeyStart, with: "\(parameters.start)")
        retValue = retValue.replacingOccurrences(of: ZomatoResources.ServerKeys.lookupKeyCount, with: "\(parameters.count)")
        retValue = retValue.replacingOccurrences(of: ZomatoResources.ServerKeys.lookupKeyLatitude, with: "\(parameters.latitude)")
        retValue = retValue.replacingOccurrences(of: ZomatoResources.ServerKeys.lookupKeyLongitude, with: "\(parameters.longitude)")
        retValue = retValue.replacingOccurrences(of: ZomatoResources.ServerKeys.lookupKeyRadius, with: "\(parameters.radius)")
        return retValue
    }
    
    func buildURLRequest(_ url: URL, using searchParameters: SearchParameters) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: searchParameters.queryTimeOut)
        request.httpMethod = searchParameters.queryType.rawValue
        request.allHTTPHeaderFields = getRequestHeaders()
        return request
    }
    
    func getRequestHeaders() -> [String: String] {
        var retValue = [String: String]()
        retValue["Accept"] = "application/json"
        retValue["user-key"] = "\(ZomatoResources.ServerKeys.zomatoAPIKey)"
        
        return retValue
    }
}

extension ZomatoRestEngine: URLSessionTaskDelegate {
    // TODO: Here is where I would put authentication challenges if they were required.
}
