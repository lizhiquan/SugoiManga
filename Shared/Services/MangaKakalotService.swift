//
//  MangaKakalotService.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-27.
//

import Combine
import Foundation

struct MangaKakalotService: MangaService {
    private let parser = MangaKakalotParser()

    private let baseURL = URL(string: "https://mangakakalot.com")!

    func latestUpdateMangasPublisher(page: Int) -> AnyPublisher<[Manga], Error> {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = "/manga_list"
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: "latest"),
            URLQueryItem(name: "category", value: "all"),
            URLQueryItem(name: "state", value: "all"),
            URLQueryItem(name: "page", value: String(page))
        ]
        let url = urlComponents.url!

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { try parser.parseMangas(from: $0.data) }
            .map { $0.filter { $0.detailURL.absoluteString.starts(with: baseURL.absoluteString) } }
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
        guard keyword.count >= 3 else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        let keyword = keyword
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "_")
        urlComponents.path = "/search/story/\(keyword)"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        let url = urlComponents.url!

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { try parser.parseSearchMangas(from: $0.data) }
            .map { $0.filter { $0.detailURL.absoluteString.starts(with: baseURL.absoluteString) } }
            .eraseToAnyPublisher()
    }
}
