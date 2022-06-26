//
//  FavoriteMangaClient.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-15.
//

import ComposableArchitecture
import Foundation

struct FavoriteMangaClient {
  var all: () -> Effect<[Manga], ClientError>
  var add: (_ manga: Manga) -> Effect<Void, ClientError>
  var remove: (_ manga: Manga) -> Effect<Void, ClientError>
  var isFavorite: (_ manga: Manga) -> Effect<Bool, ClientError>
}

// MARK: - Live

extension FavoriteMangaClient {
  static let live = Self(
    all: PersistenceController.shared.getFavorites,
    add: PersistenceController.shared.addFavorite,
    remove: PersistenceController.shared.removeFavorite,
    isFavorite: PersistenceController.shared.isFavorite
  )
}

// MARK: - Mock

extension FavoriteMangaClient {
  static let mock = Self(
    all: { fatalError("unmocked") },
    add: { manga in fatalError("unmocked") },
    remove: { manga in fatalError("unmocked") },
    isFavorite: { manga in fatalError("unmocked") }
  )
}

// MARK: - Mock

extension FavoriteMangaClient {
  static let preview = Self(
    all: { .init(value: Manga.mocks) },
    add: { manga in .init(value: ()) },
    remove: { manga in .init(value: ()) },
    isFavorite: { manga in .init(value: true) }
  )
}

// MARK: - Provider

extension PersistenceController {
  func getFavorites() -> Effect<[Manga], ClientError> {
    do {
      let mangas = try getFavoriteMangas().map(Manga.init(with:))
      return .init(value: mangas)
    } catch {
      debugPrint(#function, error)
      return .init(error: .persistence(error: error))
    }
  }

  private func getFavoriteMangas() throws -> [FavoriteManga] {
    try context.fetch(FavoriteManga.fetchRequest())
  }

  func addFavorite(manga: Manga) -> Effect<Void, ClientError> {
    do {
      let favoriteManga = try getFavorite(manga: manga)
      guard favoriteManga == nil else {
        return Effect(value: ())
      }

      _ = FavoriteManga.instance(from: manga, with: context)
      try context.save()
      return .init(value: ())
    } catch {
      debugPrint(#function, error)
      return .init(error: .persistence(error: error))
    }
  }

  func removeFavorite(manga: Manga) -> Effect<Void, ClientError> {
    do {
      guard let favoriteManga = try getFavorite(manga: manga) else {
        return Effect(value: ())
      }

      context.delete(favoriteManga)
      try context.save()
      return .init(value: ())
    } catch {
      debugPrint(#function, error)
      return .init(error: .persistence(error: error))
    }
  }

  func isFavorite(manga: Manga) -> Effect<Bool, ClientError> {
    do {
      let isFavorite = try getFavorite(manga: manga) != nil
      return .init(value: isFavorite)
    } catch {
      debugPrint(#function, error)
      return .init(error: .persistence(error: error))
    }
  }

  private func getFavorite(manga: Manga) throws -> FavoriteManga? {
    let request = FavoriteManga.fetchRequest()
    request.predicate = NSPredicate(format: "detailURL == %@", manga.detailURL.absoluteString)
    return try context.fetch(request).first
  }
}
