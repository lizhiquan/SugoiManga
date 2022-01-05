//
//  MangaDetailViewModel.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-04.
//

import Foundation
import Combine
import CoreData

@MainActor final class MangaDetailViewModel: ObservableObject {
    private let manga: Manga
    private let context: NSManagedObjectContext

    @Published private var mangaDetail: MangaDetail?
    @Published private(set) var fetching = false
    @Published private(set) var isFavorite = false

    var title: String { manga.title }
    var coverImageURL: URL? { manga.coverImageURL }
    var author: String? { mangaDetail?.author }
    var summary: String? { mangaDetail?.summary }
    var chapters: [Chapter] { mangaDetail?.chapters ?? [] }
    var mangaService: MangaService {
        manga.source.service
    }
    
    private var entity: MangaEntity?

    init(manga: Manga, context: NSManagedObjectContext) {
        self.manga = manga
        self.context = context
        
        let fetchRequest = MangaEntity.fetchRequest(manga: manga)
        if let results = try? context.fetch(fetchRequest), !results.isEmpty {
            entity = results.first
            isFavorite = true
        }
    }

    func fetchDetail() {
        Task {
            await fetchDetailAsync()
        }
    }

    func fetchDetailAsync() async {
        fetching = true
        defer { fetching = false }

        do {
            let mangaDetail = try await fetchMangaDetailAsync()
            self.mangaDetail = mangaDetail
        } catch {
            print(error)
        }
    }

    private func fetchMangaDetailAsync() async throws -> MangaDetail {
        try await withCheckedThrowingContinuation { c in
            var cancellable: AnyCancellable?
            cancellable = self.mangaService.mangaDetailPublisher(url: manga.detailURL)
                .first()
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        c.resume(throwing: error)
                    }
                    cancellable?.cancel()
                }, receiveValue: { value in
                    c.resume(returning: value)
                })
        }
    }
    
    func markAsFavorite() {
        if isFavorite {
            deleteFromCoreData()
        } else {
            saveToCoreData()
        }
    }
    
    private func saveToCoreData() {
        entity = MangaEntity(context: context)
        entity?.copy(from: manga)
        
        do {
            try context.save()
            isFavorite = true
        } catch {
            print(error)
        }
    }
    
    private func deleteFromCoreData() {
        guard let entity = entity else { return }
        
        context.delete(entity)
        
        do {
            try context.save()
            isFavorite = false
        } catch {
            print(error)
        }
    }
}
