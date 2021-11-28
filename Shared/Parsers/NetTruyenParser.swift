//
//  NetTruyenParser.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Foundation
import Kanna

struct NetTruyenParser {
    enum ParseError: Error {
        case parseFailed
    }

    func parseMangas(from data: Data) throws -> [Manga] {
        let html = try HTML(html: data, encoding: .utf8)
        guard let contentNode = html.at_css("#ctl00_divCenter") else {
            throw ParseError.parseFailed
        }

        let mangas = try contentNode.xpath("//div[@class='item']")
            .map { item -> Manga in
                let title = item.at_xpath("//div[@class='title']")?.text
                let coverPath = item.at_xpath("//div[@class='image']//img")?["data-original"] ?? ""
                let coverURL = URL(string: "https:\(coverPath)")
                let description = item.at_xpath("//div[@class='box_text']")?.text
                let detailURL = (item.at_xpath("//figcaption//a")?["href"]?
                    .replacingOccurrences(of: "http:", with: "https:") as String?)
                    .flatMap(URL.init)
                let genres = item.at_xpath("//p[label='Thể loại:']")?.text?
                    .replacingOccurrences(of: "\nThể loại:", with: "")
                    .components(separatedBy: ", ")
                let rawStatus = item.at_xpath("//p[label='Tình trạng:']")?.text?
                    .replacingOccurrences(of: "\nTình trạng:", with: "")
                let status: Manga.Status = rawStatus == "Đang tiến hành" ? .ongoing : .completed
                let rawView = item.at_xpath("//p[label='Lượt xem:']")?.text?
                    .replacingOccurrences(of: "\nLượt xem:", with: "")
                let view = (rawView?.filter({ $0.isNumber }) as String?).flatMap(Int.init)

                guard let title = title,
                      let description = description,
                      let detailURL = detailURL,
                      let genres = genres,
                      let view = view else {
                          throw ParseError.parseFailed
                      }

                return Manga(
                    title: title,
                    description: description,
                    coverImageURL: coverURL,
                    detailURL: detailURL,
                    genres: genres,
                    status: status,
                    view: view
                )
            }

        return mangas
    }

    func parseMangaDetail(from data: Data) throws -> MangaDetail {
        let html = try HTML(html: data, encoding: .utf8)
        let author = html.at_css("li.author p.col-xs-8")?.text
        let rawStatus = html.at_css("li.status p.col-xs-8")?.text
        let status: Manga.Status = rawStatus == "Đang tiến hành" ? .ongoing : .completed
        let genres = html.css("li.kind p.col-xs-8 a")
            .compactMap(\.text)
        let updatedAt = try html.at_xpath("//time")?.text
            .flatMap { content -> String? in
                let regex = try NSRegularExpression(pattern: #"\[Cập nhật lúc: (.+)\]"#, options: [])
                guard let match = regex.firstMatch(
                    in: content,
                    options: [],
                    range: NSRange(content.startIndex..<content.endIndex, in: content)
                ), let range = Range(match.range(at: 1), in: content) else {
                    return nil
                }

                return String(content[range])
            }
            .flatMap { dateStr -> Date? in
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm dd/MM/yyyy"
                formatter.locale = Locale(identifier: "vi_VN")
                return formatter.date(from: dateStr)
            }

        guard let author = author,
              let chaptersNode = html.at_css("#nt_listchapter") else {
            throw ParseError.parseFailed
        }

        let chapters = try chaptersNode.xpath("//li[@class='row' or @class='row less']")
            .map { item -> Chapter in
                let title = item.at_xpath("//a")?.text
                let updatedAt = item.xpath("//div")[1].text
                let rawView = item.xpath("//div")[2].text
                let view = (rawView?.filter({ $0.isNumber }) as String?).flatMap(Int.init)
                let detailURL = (item.at_xpath("//a")?["href"]?
                    .replacingOccurrences(of: "http:", with: "https:") as String?)
                    .flatMap(URL.init)

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
        let imageURLs = try html.xpath("//div[@class='page-chapter']/img")
            .map { item -> URL in
                guard let path = item["data-original"],
                      let url = URL(
                        string: path.hasPrefix("http") ? path : "https:\(path)"
                      ) else {
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
