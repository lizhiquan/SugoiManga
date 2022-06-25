//
//  MangaService.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-03.
//

import Combine
import Foundation

protocol MangaService {
  func latestUpdateMangas(page: Int) -> AnyPublisher<[Manga], ClientError>
  func mangaDetail(url: URL) -> AnyPublisher<MangaDetail, ClientError>
  func chapterDetail(url: URL) -> AnyPublisher<ChapterDetail, ClientError>
  func searchMangas(keyword: String, page: Int) -> AnyPublisher<[Manga], ClientError>
}
