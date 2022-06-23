//
//  ManganatoParser.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-12-04.
//

import Foundation
import Kanna

struct ManganatoParser {
  func parseMangaDetail(from data: Data) throws -> MangaDetail {
    let html = try HTML(html: data, encoding: .utf8)

    let author = html.at_css(".info-author")?.parent?.parent?
      .at_css(".table-value")?.text?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let rawStatus = html.at_css(".info-status")?.parent?.parent?
      .at_css(".table-value")?.text
    let status: Manga.Status = rawStatus == "Ongoing" ? .ongoing : .completed
    let genres = html.at_css(".info-genres")?.parent?.parent?
      .css(".table-value a")
      .compactMap(\.text) ?? []
    let updatedAt = html.at_css(".info-time")?.parent?.parent?.at_css(".stre-value")?.text
      .flatMap { dateStr -> Date? in
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy - HH:mm a"
        formatter.timeZone = TimeZone(identifier: "UTC+0800")
        return formatter.date(from: dateStr)
      }
    let summaryNode = html.at_css("#panel-story-info-description")
    summaryNode?.at_css("h3").flatMap { summaryNode?.removeChild($0) }
    let summary = summaryNode?.text?.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let author = author,
          let summary = summary else {
      throw NSError()
    }

    let chapters = try html.css("li.a-h")
      .map { item -> Chapter in
        let title = item.at_css("a")?.text
        let updatedAt = item.at_css("span.chapter-time")?.text?
          .trimmingCharacters(in: .whitespacesAndNewlines)
        let rawView = item.at_css("span.chapter-view")?.text
        let view = (rawView?.filter({ $0.isNumber }) as String?).flatMap(Int.init)
        let detailURL = item.at_css("a")?["href"].flatMap(URL.init)

        guard let title = title,
              let updatedAt = updatedAt,
              let detailURL = detailURL else {
          throw NSError()
        }

        return Chapter(
          title: title,
          updatedAt: updatedAt,
          view: view,
          detailURL: detailURL
        )
      }

    let mangaDetail = MangaDetail(
      summary: summary,
      updatedAt: updatedAt,
      chapters: chapters,
      author: author,
      genres: genres,
      status: status
    )

    return mangaDetail
  }

  func parseChapterDetail(from data: Data, baseURL: URL) throws -> ChapterDetail {
    let html = try HTML(html: data, encoding: .utf8)
    let imageURLs = try html.css(".container-chapter-reader img")
      .map { item -> URL in
        guard let url = item["src"].flatMap(URL.init) else {
          throw NSError()
        }
        return url
      }
    let imageRequestHeaders = ["Referer": baseURL.absoluteString]

    let chapterDetail = ChapterDetail(
      imageURLs: imageURLs,
      imageRequestHeaders: imageRequestHeaders
    )

    return chapterDetail
  }
}
