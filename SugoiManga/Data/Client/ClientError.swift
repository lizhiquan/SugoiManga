//
//  ClientError.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-21.
//

import Foundation

enum ClientError: Error, Equatable {
  case network(error: Error)
  case decoding
  case persistence(error: Error)

  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.network(let lhsError), .network(let rhsError)):
      return String(reflecting: lhsError) == String(reflecting: rhsError)

    case (.decoding, .decoding):
      return true

    case (.persistence(let lhsError), .persistence(let rhsError)):
      return String(reflecting: lhsError) == String(reflecting: rhsError)

    default:
      return false
    }
  }
}
