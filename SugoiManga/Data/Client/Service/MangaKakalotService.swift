//
//  MangaKakalotService.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-27.
//

import Combine
import Foundation

class MangaKakalotService: MangaService {
  static let shared = MangaKakalotService()

  private let mangaKakalotParser = MangaKakalotParser()
  private let manganatoParser = ManganatoParser()

  private let baseURL = URL(string: "https://mangakakalot.com")!

  func latestUpdateMangas(page: Int) -> AnyPublisher<[Manga], ClientError> {
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
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap { try mangaKakalotParser.parseMangas(from: $0) }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }

  func mangaDetail(url: URL) -> AnyPublisher<MangaDetail, ClientError> {
    URLSession.shared.dataTaskPublisher(for: url)
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap {
            if isManganato(url: url) {
              return try manganatoParser.parseMangaDetail(from: $0)
            }

            return try mangaKakalotParser.parseMangaDetail(from: $0)
          }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }

  func chapterDetail(url: URL) -> AnyPublisher<ChapterDetail, ClientError> {
    URLSession.shared.dataTaskPublisher(for: url)
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap {
            if isManganato(url: url) {
              return try manganatoParser.parseChapterDetail(from: $0, baseURL: url)
            }

            return try mangaKakalotParser.parseChapterDetail(from: $0, baseURL: baseURL)
          }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }

  func searchMangas(keyword: String, page: Int) -> AnyPublisher<[Manga], ClientError> {
    guard keyword.count >= 3 else {
      return Just([])
        .setFailureType(to: ClientError.self)
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
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap { try mangaKakalotParser.parseSearchMangas(from: $0) }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }

  private func isManganato(url: URL) -> Bool {
    ["managato.com", "readmanganato.com"].contains(url.host)
  }
}
