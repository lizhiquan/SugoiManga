//
//  CenterModifier.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-12-01.
//

import SwiftUI

struct CenterModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

extension View {
    func center() -> some View {
        modifier(CenterModifier())
    }
}
