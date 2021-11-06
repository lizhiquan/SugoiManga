//
//  NetTruyenService.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Combine
import Foundation

struct NetTruyenService: MangaService {
    private let parser = NetTruyenParser()

    func latestUpdateMangasPublisher() -> AnyPublisher<[Manga], Error> {
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.nettruyenpro.com")!)
            .tryMap { try parser.parseMangas(from: $0.data) }
            .eraseToAnyPublisher()
    }

    func mangaDetailPublisher(url: URL) -> AnyPublisher<MangaDetail, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { try parser.parseMangaDetail(from: $0.data) }
            .eraseToAnyPublisher()
    }
}
