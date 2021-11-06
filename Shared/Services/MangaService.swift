//
//  MangaService.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Combine
import Foundation

protocol MangaService {
    func latestUpdateMangasPublisher() -> AnyPublisher<[Manga], Error>
    func mangaDetailPublisher(url: URL) -> AnyPublisher<MangaDetail, Error>
}
