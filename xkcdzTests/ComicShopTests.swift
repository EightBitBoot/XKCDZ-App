//
//  xkcdzTests.swift
//  xkcdzTests
//
//  Created by Adin W-T on 6/11/23.
//

import XCTest
@testable import xkcdz

final class ComicShopTests: XCTestCase {
    var shop: ComicShop!
    
    override func setUpWithError() throws {
        shop = ComicShop()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDownloadFirst() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        let meta: ComicMeta = try await shop.getMeta(for: 1)
        
        XCTAssertEqual(meta.id, 1)
        XCTAssertEqual(meta.title, "Barrel - Part 1")
        XCTAssertEqual(meta.safeTitle, "Barrel - Part 1")
        XCTAssertEqual(meta.alt, "Don't we all.")
        let components = DateComponents(timeZone: TimeZone.current, year: 2006, month: 1, day: 1)
        XCTAssertEqual(meta.date, Calendar(identifier: .gregorian).date(from: components)!)
        XCTAssertEqual(meta.img, "https://imgs.xkcd.com/comics/barrel_cropped_(1).jpg")
    }
    
    func testDownloadLatest() async throws {
        let meta: ComicMeta = try await shop.getMeta()
        meta.dump()
    }
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
