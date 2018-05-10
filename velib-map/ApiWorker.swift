//
//  ApiWorker.swift
//  velib-map
//
//  Created by Thomas Guilleminot on 14/08/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Promises

enum APIError: LocalizedError {
  case notFound
  
  var errorDescription: String? {
    switch self {
    case .notFound:
      return "Une erreur est survenue"
    }
  }
}

class ApiWorker {
  
  static func fetchPins() -> Promise<[Station]> {
    return Promise<[Station]> { fulfill, reject in
      var stations = [Station]()
      
      Alamofire.request(Api.allStationsFrom(.paris).url).validate().responseJSON { response in
        guard response.result.isSuccess
          else { return reject(APIError.notFound) }
        
        let responseJSON = JSON(response.value as Any)
        _ = responseJSON.map { $0.1 }.map {
        let station = Mapper.mapStations(newsJSON: $0)
          stations.append(station)
        }
        
        fulfill(stations)
      }
    }
  }
    
  static func fetchAllStations(favoriteStations: [FavoriteStation]) -> Promise<[Station]> {
    return Promise<[Station]> { fulfill, reject in
      var fetchedStations = [Station]()
      
      _ = favoriteStations.map { station in
        Alamofire.request(Api.stationFrom(station.number).url).validate().responseJSON { response in
          guard response.result.isSuccess
            else { return reject(APIError.notFound) }
          
          let responseJSON = JSON(response.value as Any)
          let station = Mapper.mapStations(newsJSON: responseJSON)
          fetchedStations.append(station)
          
          if fetchedStations.count == favoriteStations.count {
            fulfill(fetchedStations)
          }
        }
      }
    }
  }
  
}
