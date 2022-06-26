//
//  SystemEnvironment.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-11.
//

import ComposableArchitecture

@dynamicMemberLookup
struct SystemEnvironment<Environment> {
  var environment: Environment
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var mangaClient: MangaClient
  var favoriteMangaClient: FavoriteMangaClient
}

extension SystemEnvironment {
  subscript<Dependency>(
    dynamicMember keyPath: WritableKeyPath<Environment, Dependency>
  ) -> Dependency {
    get { self.environment[keyPath: keyPath] }
    set { self.environment[keyPath: keyPath] = newValue }
  }
}

extension SystemEnvironment {
  static func live(environment: Environment) -> Self {
    Self(
      environment: environment,
      mainQueue: .main,
      mangaClient: .live,
      favoriteMangaClient: .live
    )
  }

  static func dev(environment: Environment) -> Self {
    Self(
      environment: environment,
      mainQueue: .main,
      mangaClient: .preview,
      favoriteMangaClient: .preview
    )
  }
}
