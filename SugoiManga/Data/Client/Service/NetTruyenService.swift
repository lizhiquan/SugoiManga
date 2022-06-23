//
//  NetTruyenService.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-03.
//

import Combine
import Foundation
import Kanna

class NetTruyenService: MangaService {
  static let shared = NetTruyenService()

  private let baseURL = URL(string: "https://www.nettruyenpro.com")!

  private let parser = NetTruyenParser()
  
  func latestUpdateMangas(page: Int) -> AnyPublisher<[Manga], ClientError> {
    var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
    urlComponents.queryItems = [URLQueryItem(name: "page", value: String(page))]
    let url = urlComponents.url!
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap { try parser.parseMangas(from: $0) }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }
  
  func mangaDetail(url: URL) -> AnyPublisher<MangaDetail, ClientError> {
    URLSession.shared.dataTaskPublisher(for: url)
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap { try parser.parseMangaDetail(from: $0) }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }
  
  func chapterDetail(url: URL) -> AnyPublisher<ChapterDetail, ClientError> {
    URLSession.shared.dataTaskPublisher(for: url)
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap { try parser.parseChapterDetail(from: $0, baseURL: baseURL) }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }
  
  func searchMangas(keyword: String, page: Int) -> AnyPublisher<[Manga], ClientError> {
    var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
    urlComponents.path = "/tim-truyen"
    urlComponents.queryItems = [
      URLQueryItem(name: "keyword", value: keyword),
      URLQueryItem(name: "page", value: String(page))
    ]
    let url = urlComponents.url!
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .mapError { .network(error: $0) }
      .flatMap { [self] in
        Just($0.data)
          .tryMap { try parser.parseMangas(from: $0) }
          .mapError { _ in .decoding }
      }
      .eraseToAnyPublisher()
  }
}
