//
//  MangaSource.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-27.
//

import Foundation

enum MangaSource: String, CaseIterable, Identifiable {
    case netTruyen = "nettruyen"
    case mangaKakalot = "mangakakalot"

    var id: MangaSource { self }
}

extension MangaSource {
    private static let netTruyenService = NetTruyenService()
    private static let mangaKakalotService = MangaKakalotService()
    
    var service: MangaService {
        switch self {
        case .netTruyen:
            return Self.netTruyenService

        case .mangaKakalot:
            return Self.mangaKakalotService
        }
    }
}
