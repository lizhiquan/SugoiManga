//
//  MangaKakalotParser.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-27.
//

import Foundation
import Kanna

struct MangaKakalotParser {
    enum ParseError: Error {
        case parseFailed
    }

    func parseMangas(from data: Data) throws -> [Manga] {
        let html = try HTML(html: data, encoding: .utf8)
        guard let contentNode = html.at_css(".truyen-list") else {
            throw ParseError.parseFailed
        }

        let mangas = try contentNode.xpath("//div[@class='list-truyen-item-wrap']")
            .map { item -> Manga in
                let title = item.at_xpath("//h3/a")?.text
                let coverURL = item.at_xpath("//img")?["src"].flatMap(URL.init)
                let detailURL = item.at_xpath("//h3/a")?["href"].flatMap(URL.init)

                let description = item.at_xpath("//p")?.text?
                    .dropFirst()
                    .replacingOccurrences(of: "More.\n", with: "")
                let rawView = item.at_xpath("//span")?.text
                let view = (rawView?.filter({ $0.isNumber }) as String?).flatMap(Int.init)

                guard let title = title,
                      let description = description,
                      let detailURL = detailURL,
                      let view = view else {
                          throw ParseError.parseFailed
                      }

                return Manga(
                    title: title,
                    description: description,
                    coverImageURL: coverURL,
                    detailURL: detailURL,
                    genres: [],
                    status: nil,
                    view: view
                )
            }

        return mangas
    }

    func parseMangaDetail(from data: Data) throws -> MangaDetail {
        let html = try HTML(html: data, encoding: .utf8)

        guard let infoNode = html.at_css("ul.manga-info-text") else {
            throw ParseError.parseFailed
        }

        let author = infoNode.at_xpath("/li[2]/a")?.text
        let rawStatus = infoNode.at_xpath("/li[3]")?.text?.replacingOccurrences(of: "Status : ", with: "")
        let status: Manga.Status = rawStatus == "Ongoing" ? .ongoing : .completed
        let genres = infoNode.xpath("/li[7]/a").compactMap(\.text)
        let updatedAt = (infoNode.at_xpath("/li[4]")?.text?
            .replacingOccurrences(of: "Last updated : ", with: "") as String?)
            .flatMap { dateStr -> Date? in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM-dd-yyyy HH:mm:ss a"
                formatter.timeZone = TimeZone(identifier: "UTC+0800")
                return formatter.date(from: dateStr)
            }


        let chapters = try html.css("div.chapter-list div.row")
            .map { item -> Chapter in
                let title = item.at_xpath("//a")?.text
                let rawView = item.at_xpath("/span[2]")?.text
                let view = (rawView?.filter({ $0.isNumber }) as String?).flatMap(Int.init)
                let updatedAt = item.at_xpath("/span[3]")?.text
                let detailURL = item.at_xpath("//a")?["href"].flatMap(URL.init)

                guard let title = title,
                      let updatedAt = updatedAt,
                      let detailURL = detailURL else {
                          throw ParseError.parseFailed
                      }

                return Chapter(
                    title: title,
                    updatedAt: updatedAt,
                    view: view,
                    detailURL: detailURL
                )
            }

        guard let author = author else {
            throw ParseError.parseFailed
        }

        let mangaDetail = MangaDetail(
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
        let imageURLs = try html.xpath("//div[@class='container-chapter-reader']/img")
            .map { item -> URL in
                guard let url = item["src"].flatMap(URL.init) else {
                    throw ParseError.parseFailed
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
