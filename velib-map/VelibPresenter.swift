//
//  VelibPresenter.swift
//  velib-map
//
//  Created by Thomas Guilleminot on 13/08/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation
import MagicSwiftBus

@objc protocol VelibEventBus {
  @objc optional func fetchPinsSuccess(stations: [Station])
  @objc optional func addFavoriteSuccess(favoriteStation: FavoriteStation)
  @objc optional func removeFavoriteSuccess()
  @objc optional func failure(error: String)
}

class VelibPresenter: Bus {
  
  public enum EventBus: String, EventBusType {
    case fetchPinsSuccess
    case addFavoriteSuccess
    case removeFavoriteSuccess
    case failure
    
    public var notification: Selector {
      switch self {
      case .fetchPinsSuccess:
        return #selector(VelibEventBus.fetchPinsSuccess(stations:))
      case .addFavoriteSuccess:
        return #selector(VelibEventBus.addFavoriteSuccess(favoriteStation:))
      case .removeFavoriteSuccess:
        return #selector(VelibEventBus.removeFavoriteSuccess)
      case .failure:
        return #selector(VelibEventBus.failure(error:))
      }
    }
  }
  
  public func fetchPinsSuccess(stations: [Station]) {
    VelibPresenter.postOnMainThread(event: .fetchPinsSuccess, object: stations as AnyObject)
  }
  
  public func addFavoriteSuccess(favoriteStation: FavoriteStation) {
    VelibPresenter.postOnMainThread(event: .addFavoriteSuccess, object: favoriteStation)
  }
  
  public func removeFavoriteSuccess() {
    VelibPresenter.postOnMainThread(event: .removeFavoriteSuccess, object: nil)
  }
  
  public func failure(error: String) {
    VelibPresenter.postOnMainThread(event: .failure, object: error as AnyObject)
  }
  
}

