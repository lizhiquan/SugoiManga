//
//  MangaGrid.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-07-09.
//

import SwiftUI

struct MangaGrid<Content: View>: View {
  @ViewBuilder var content: () -> Content

  var body: some View {
    let columns = [GridItem(
      .adaptive(minimum: UIDevice.current.userInterfaceIdiom == .pad ? 150 : 110),
      spacing: 12
    )]
    LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
      content()
    }
  }
}
