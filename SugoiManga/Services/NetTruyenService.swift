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

    func latestUpdateMangasPublisher(page: Int) -> AnyPublisher<[Manga], Error> {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "page", value: String(page))]
        let url = urlComponents.url!

        return URLSession.shared.dataTaskPublisher(for: url)
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

    func searchMangasPublisher(keyword: String, page: Int) -> AnyPublisher<[Manga], Error> {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = "/tim-truyen"
        urlComponents.queryItems = [
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "page", value: String(page))
        ]
        let url = urlComponents.url!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { try parser.parseMangas(from: $0.data) }
            .eraseToAnyPublisher()
    }
}
