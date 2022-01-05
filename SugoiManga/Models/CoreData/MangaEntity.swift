//
//  MangaEntity.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-01-03.
//

import Foundation
import CoreData

@objc(MangaEntity)
class MangaEntity: NSManagedObject {
    class func fetchRequest(manga: Manga) -> NSFetchRequest<MangaEntity> {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "detailURL == %@", manga.detailURL.absoluteString)
        return fetchRequest
    }
    
    func copy(from manga: Manga) {
        self.title = manga.title
        self.coverImageURL = manga.coverImageURL
        self.detailURL = manga.detailURL
        self.genres = manga.genres as NSObject
        self.status = (manga.status?.rawValue).flatMap(NSNumber.init)
        self.view = NSNumber(value: manga.view)
        self.source = manga.source.rawValue
    }
}
