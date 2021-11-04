//
//  NetTruyenService.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Combine
import Foundation

struct NetTruyenService: MangaService {
    func latestUpdateMangasPublisher() -> AnyPublisher<[Manga], Error> {
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.nettruyenpro.com")!)
            .tryMap { try NetTruyenParser().parseMangas(from: $0.data) }
            .eraseToAnyPublisher()
    }
}
