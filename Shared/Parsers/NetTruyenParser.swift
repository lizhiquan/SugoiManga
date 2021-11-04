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

        return try contentNode.xpath("//div[@class='item']")
            .map { item in
                let title = item.at_xpath("//div[@class='title']")?.text
                let coverPath = item.at_xpath("//div[@class='image']//img")?["data-original"] ?? ""
                let coverURL = URL(string: "https:\(coverPath)")
                let description = item.at_xpath("//div[@class='box_text']")?.text
                let detailURL = item.at_xpath("//figcaption//a")?["href"] .flatMap(URL.init)
                let author = item.at_xpath("//p[label='Tác giả:']")?.text?
                    .replacingOccurrences(of: "\nTác giả:", with: "") ?? ""
                let categories = item.at_xpath("//p[label='Thể loại:']")?.text?
                    .replacingOccurrences(of: "\nThể loại:", with: "")
                    .components(separatedBy: ", ")
                let rawStatus = item.at_xpath("//p[label='Tình trạng:']")?.text?
                    .replacingOccurrences(of: "\nTình trạng:", with: "")
                let status: Manga.Status = rawStatus == "Đang tiến hành" ? .ongoing : .finished
                let rawViews = item.at_xpath("//p[label='Lượt xem:']")?.text?
                    .replacingOccurrences(of: "\nLượt xem:", with: "")
                let views = (rawViews?.filter({ $0.isNumber }) as String?).flatMap(Int.init)

                guard let title = title,
                      let description = description,
                      let detailURL = detailURL,
                      let categories = categories,
                      let views = views else {
                          throw ParseError.parseFailed
                      }

                return Manga(
                    title: title,
                    description: description,
                    author: author,
                    coverImageURL: coverURL,
                    detailURL: detailURL,
                    categories: categories,
                    status: status,
                    views: views
                )
            }
    }
}
