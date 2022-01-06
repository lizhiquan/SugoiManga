//
//  FavoriteView.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-01-03.
//

import SwiftUI

struct FavoriteView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: MangaEntity.entity(),
        sortDescriptors: []
    ) var mangas: FetchedResults<MangaEntity>
    
    var body: some View {
        NavigationView {
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(mangas) { mangaEntity in
                        let manga = Manga(from: mangaEntity)
                        let detailView = MangaDetailView(manga: manga, context: managedObjectContext)
                        NavigationLink(destination: detailView) {
                            MangaView(manga: manga)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Favorite")
        }
        .navigationViewStyle(.stack)
    }
}
