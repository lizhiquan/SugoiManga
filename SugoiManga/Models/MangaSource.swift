//
//  MangaSource.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-27.
//

import Foundation

enum MangaSource: String, CaseIterable, Identifiable {
    case netTruyen = "Net Truyen"
    case mangaKakalot = "Manga Kakalot"

    var id: MangaSource { self }
}

extension MangaSource {
    var service: MangaService {
        switch self {
        case .netTruyen:
            return NetTruyenService()

        case .mangaKakalot:
            return MangaKakalotService()
        }
    }
}
