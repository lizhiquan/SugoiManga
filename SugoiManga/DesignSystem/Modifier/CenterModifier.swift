//
//  CenterModifier.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-12-01.
//

import SwiftUI

struct HCenterModifier: ViewModifier {
  func body(content: Content) -> some View {
    HStack {
      Spacer()
      content
      Spacer()
    }
  }
}

struct VCenterModifier: ViewModifier {
  func body(content: Content) -> some View {
    VStack {
      Spacer()
      content
      Spacer()
    }
  }
}

extension View {
  func hCenter() -> some View {
    modifier(HCenterModifier())
  }

  func vCenter() -> some View {
    modifier(VCenterModifier())
  }
}
