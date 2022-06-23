//
//  FavoriteManga.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-01-03.
//

import CoreData

extension FavoriteManga {
  static func instance(from manga: Manga, with context: NSManagedObjectContext) -> Self {
    let favoriteManga = Self(context: context)

    favoriteManga.title = manga.title
    favoriteManga.coverImageURL = manga.coverImageURL
    favoriteManga.detailURL = manga.detailURL
    favoriteManga.genres = manga.genres as NSObject
    favoriteManga.status = (manga.status?.rawValue).flatMap(NSNumber.init)
    favoriteManga.view = NSNumber(value: manga.view)
    favoriteManga.sourceID = manga.sourceID.rawValue

    return favoriteManga
  }
}
