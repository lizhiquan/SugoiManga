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

    private let baseURL = URL(string: "https://www.nettruyenpro.com")!

    func latestUpdateMangasPublisher() -> AnyPublisher<[Manga], Error> {
        URLSession.shared.dataTaskPublisher(for: baseURL)
            .tryMap { try parser.parseMangas(from: $0.data) }
            .eraseToAnyPublisher()
    }

    func mangaDetailPublisher(url: URL) -> AnyPublisher<MangaDetail, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { try parser.parseMangaDetail(from: $0.data) }
            .eraseToAnyPublisher()
    }

    func chapterDetailPublisher(url: URL) -> AnyPublisher<ChapterDetail, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { try parser.parseChapterDetail(from: $0.data, baseURL: baseURL) }
            .eraseToAnyPublisher()
    }

    func searchMangasPublisher(keyword: String) -> AnyPublisher<[Manga], Error> {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = "/tim-truyen"
        urlComponents.queryItems = [URLQueryItem(name: "keyword", value: keyword)]
        
        return URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            .tryMap { try parser.parseMangas(from: $0.data) }
            .eraseToAnyPublisher()
    }
}
