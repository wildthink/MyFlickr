//
//  FlickrRequest.swift
//  MyFlickr
//
//  Created by Jason Jobe on 9/13/24.
//


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let flickrRequest = try? JSONDecoder().decode(FlickrRequest.self, from: jsonData)

import Foundation
import SwiftSoup

// MARK: - FlickrRequest
struct FlickrRequest: Codable {
    let title: String
    let link: String
    let description: String
    let modified: Date
    let generator: String
    let items: [Item]
}

// MARK: - Item
struct Item: Codable, Equatable {
    let title: String
    let link: String
    let media: Media
    let dateTaken: Date
    let description: String
    let published: Date
    let author, authorID, tags: String

    enum CodingKeys: String, CodingKey {
        case title, link, media
        case dateTaken = "date_taken"
        case description, published, author
        case authorID = "author_id"
        case tags
    }
    
    // Derived values
    var imageInfo: HTMLImg?
    var caption: String

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.link = try container.decode(String.self, forKey: .link)
        self.media = try container.decode(Media.self, forKey: .media)
        self.dateTaken = try container.decode(Date.self, forKey: .dateTaken)
        self.description = try container.decode(String.self, forKey: .description)
        self.published = try container.decode(Date.self, forKey: .published)
        self.author = try container.decode(String.self, forKey: .author)
        self.authorID = try container.decode(String.self, forKey: .authorID)
        self.tags = try container.decode(String.self, forKey: .tags)
                    
        var str = ""
        do {
            let doc: Document = try SwiftSoup.parse(self.description)
            if let p = try doc.select("p").last() {
                try print(p.text(), to: &str)
            }
            
            if let img = try? doc.select("img").first() {
                imageInfo = HTMLImg(with: img)
            }
        } catch {
            log.error("\(error)")
        }
        caption = str
    }

}

// MARK: - Media
struct Media: Codable, Equatable {
    let m: String
}

// MARK: App Extensions & Preview Data

extension JSONDecoder {
    static var standard: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension FlickrRequest {
    static let jsonData = "/Users/jason/dev/labs/MyFlickr/MyFlickr/Preview Content/flickr.json"
    
    static var preview: Self = {
        let data = try! Data(contentsOf: URL(filePath: jsonData))
        return try! JSONDecoder.standard.decode(FlickrRequest.self, from: data)
    }()
}

extension Item: Identifiable {
    var id: String { link }
    
    var imageURL: URL? { URL(string: self.media.m) }

    static var preview: Item {
        FlickrRequest.preview.items[0]
    }
}

extension [Item] {
    static var preview: Self {
        FlickrRequest.preview.items
    }
}

/*
 "description": " <p><a href=\"https:\/\/www.flickr.com\/people\/199973440@N02\/\">gwylligi<\/a> posted a photo:<\/p> <p><a href=\"https:\/\/www.flickr.com\/photos\/199973440@N02\/53988888706\/\" title=\"Sleeping Pincushon\"><img src=\"https:\/\/live.staticflickr.com\/65535\/53988888706_b368cb9958_m.jpg\" width=\"240\" height=\"160\" alt=\"Sleeping Pincushon\" \/><\/a><\/p> <p>A porcupine takes an afternoon nap at the National Zoo<\/p> ",

 */
struct HTMLImg: Equatable {
    var src: URL
    var alt: String?
    var width: CGFloat?
    var height: CGFloat?
    
    init?(with el: Element) {
        guard let src = try? el.attr("src"),
           let url = URL(string: src)
        else {
            return nil
        }
        self.src = url
        self.alt = try? el.attr("alt")
        
        if let str = try? el.attr("width"),
           let dv = Double(str) {
            self.width = CGFloat(dv)
        }
        if let str = try? el.attr("height"),
           let dv = Double(str) {
            self.height = CGFloat(dv)
        }
    }
}
