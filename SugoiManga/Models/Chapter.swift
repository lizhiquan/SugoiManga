//
//  Chapter.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-05.
//

import Foundation

struct Chapter: Identifiable {
    let title: String
    let updatedAt: String
    let view: Int?
    let detailURL: URL

    var id: String { title }
}
