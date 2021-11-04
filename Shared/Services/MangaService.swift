//
//  MangaService.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Combine

protocol MangaService {
    func latestUpdateMangasPublisher() -> AnyPublisher<[Manga], Error>
}
