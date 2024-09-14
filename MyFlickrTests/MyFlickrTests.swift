//
//  MyFlickrTests.swift
//  MyFlickrTests
//
//  Created by Jason Jobe on 9/13/24.
//

import XCTest
@testable import MyFlickr
import SwiftSoup

final class MyFlickrTests: XCTestCase {
    let jsonData = "/Users/jason/dev/labs/MyFlickr/MyFlickr/Preview Content/flickr.json"
    
    // Sanity check for quicktype.io
    func testForValidJSON() throws {
        let data = try Data(contentsOf: URL(filePath: jsonData))
        let req = try JSONDecoder.standard.decode(FlickrRequest.self, from: data)
        
        // This would be preferred
//        assertSnapshot(of: req.items[0], as: .json)
        XCTAssert(req.title == "Recent Uploads tagged porcupine")
        XCTAssert(req.items[0].title == "Sleeping Pincushon")
    }
    
    func testHTMLImg() throws {
        let tag = #"<img src="https://live.staticflickr.com/65535/53988888706_b368cb9958_m.jpg" width="240" height="160" alt="Sleeping Pincushon" />"#
        
        let doc: Document = try SwiftSoup.parse(tag)

        if let img = try? doc.select("img").first(),
           let himg = HTMLImg(with: img) {
            // This would be preferred
//            assertSnapshot(of: himg, as: .json)
            XCTAssert(himg.width == 240)
            XCTAssert(himg.height == 160)
        } else {
            XCTFail("Unable to create HTMLImg")
        }
    }
}
