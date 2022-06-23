//
//  ActivityIndicator.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-19.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
  typealias UIViewType = UIActivityIndicatorView
  let style: UIActivityIndicatorView.Style
  let color: UIColor
  let isAnimating: Bool

  public init(style: UIActivityIndicatorView.Style, color: UIColor = .black, isAnimating: Bool) {
    self.style = style
    self.color = color
    self.isAnimating = isAnimating
  }

  func makeUIView(context: Context) -> UIActivityIndicatorView {
    let activityIndicatorView = UIActivityIndicatorView()
    updateUIView(activityIndicatorView, context: context)
    return activityIndicatorView
  }

  func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    uiView.style = style
    uiView.color = color
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
  }
}
