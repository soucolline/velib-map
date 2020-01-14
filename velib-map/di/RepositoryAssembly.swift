//
//  RepositoryAssembly.swift
//  velib-map
//
//  Created by Thomas Guilleminot on 14/01/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import Foundation
import Swinject

// swiftlint:disable force_unwrapping
class RepositoryAssembly: Assembly {
  func assemble(container: Container) {
    container.register(PreferencesRepository.self) { resolver in
      PreferencesRepository(
        with: resolver.resolve(UserDefaults.self)!
      )
    }

    container.register(FavoriteRepository.self) { resolver in
      FavoriteRepository(
        with: resolver.resolve(UserDefaults.self)!
      )
    }
  }
}
