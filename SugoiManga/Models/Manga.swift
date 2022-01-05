//
//  Manga.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Foundation

struct Manga: Identifiable, Equatable {
    
    let title: String
    let coverImageURL: URL?
    let detailURL: URL
    let genres: [String]
    let status: Status?
    let view: Int
    let source: MangaSource

    enum Status: Int32 {
        case ongoing = 0
        case completed = 1
    }

    var id: URL { detailURL }
    
    init(title: String,
         coverImageURL: URL?,
         detailURL: URL,
         genres: [String],
         status: Manga.Status?,
         view: Int,
         source: MangaSource
    ) {
        self.title = title
        self.coverImageURL = coverImageURL
        self.detailURL = detailURL
        self.genres = genres
        self.status = status
        self.view = view
        self.source = source
    }
    
    init(from entity: MangaEntity) {
        self.title = entity.title!
        self.coverImageURL = entity.coverImageURL
        self.detailURL = entity.detailURL!
        self.genres = (entity.genres as? [String]) ?? []
        self.status = entity.status.flatMap { Manga.Status(rawValue: $0.int32Value) }
        self.view = entity.view?.intValue ?? 0
        self.source = MangaSource(rawValue: entity.source!)!
    }
}
