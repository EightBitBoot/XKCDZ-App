//
//  ComicShop.swift
//  xkcdz
//
//  Created by Adin W-T on 12/29/23.
//

import Foundation
import Dispatch
import RealmSwift
import os

// TODO(Adin): Convert realm to queue isolated realm and
//             use withCheckedContinuation(block:) to
//             bridge it

// TODO(Adin): Create download task map to avoid re-downloading
//             of currently-downloading content (in downloadData(for:))

// TODO(Adin):
// struct?
actor ComicShop {
    static let shared: ComicShop = ComicShop()
    static let logger: os.Logger = os.Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ComicShop.self)
    )

    private init() {
        Self.logger.info("Cache directory: \(ComicShop.CACHE_DIR_URL.absoluteString, privacy: .public)")
    }

    // TODO(Adin): Make this more externally readable by creating a dedicated
    //             downloadLatestMeta() function?
    func downloadMeta(for comicNum: Int? = nil) async throws {
        let realm = try await Realm(configuration: XKCDZ_SHARED_REALM_CONFIG, actor: self)
        if comicNum != nil && realm.objects(ComicMeta.self).contains(where: {$0.id == comicNum}) {
            return
        }

        let meta = try await downloadAndParseMeta(for: comicNum)
        if comicNum == nil && realm.objects(ComicMeta.self).contains(where: {$0.id == meta.id}) {
            return
        }
        try realm.write {
            realm.add(meta)
        }
    }

    func getImage(for comicNum: Int, size: ImageSize = .Large) async throws -> Data {
        ensureCacheDir()

        // ---- Try loading from filesystem ----
        let fileName   = String(describing: comicNum)
        let fileName2x = String(describing: comicNum) + "_2x"

        let effectiveFilePath: URL
        switch(size) {
            case .Standard:
                effectiveFilePath = ComicShop.CACHE_DIR_URL.appendingPathComponent(fileName)

            case .Large:
                effectiveFilePath = ComicShop.CACHE_DIR_URL.appendingPathComponent(fileName2x)
        }

        var fileData: Data?
        do {
            fileData = try Data(contentsOf: effectiveFilePath)
        }
        catch let error as NSError where error.code == Foundation.NSFileReadNoSuchFileError {
            // GULP (this is the only error that should prompt a download:
            //       all others should be passed up the stack)
            fileData = nil
        }

        if let fileData = fileData {
            Self.logger.debug("""
                Img Cache Hit:
                    comicNum=\(comicNum, privacy: .public)
                    "size=\(size == .Large ? "large" : "standard", privacy: .public)
                    "path=\(effectiveFilePath, privacy: .public)
                """
            )
            return fileData
        }


        // ---- Try downloading from url ----

        let realm = try! await Realm(configuration: XKCDZ_SHARED_REALM_CONFIG, actor: self)
        if !realm.objects(ComicMeta.self).contains(where: { $0.id == comicNum}) {
            // Although downloadMeta(for:) checks whether the meta to download already exists,
            // it is better to still check here to avoid needing to open another realm inside
            // downloadMeta (if possible)
            try await downloadMeta(for: comicNum)
        }
        let meta = realm.objects(ComicMeta.self).first(where: { $0.id == comicNum})!

        let imgUrl = meta.img

        let imgName2x = meta.img.deletingPathExtension().lastPathComponent + "_2x." + meta.img.pathExtension
        let imgUrl2x  = meta.img.deletingLastPathComponent().appendingPathComponent(imgName2x)

        let effectiveUrl: URL
        switch(size) {
        case .Standard:
            effectiveUrl = imgUrl

        case .Large:
            effectiveUrl = imgUrl2x
        }

        Self.logger.debug("""
            Img Cache Miss:
                comicNum=\(comicNum, privacy: .public)
                size=\((size == .Large ? "large" : "standard"), privacy: .public)
                path=\(effectiveFilePath, privacy: .public)
                url=\(effectiveUrl, privacy: .public)
            """
        )

        let downloadedData = try await downloadData(from: effectiveUrl)
        try downloadedData.write(to: effectiveFilePath)

        return downloadedData
    }

    func getLargestImage(for comicNum: Int) async throws -> Data {
        do {
            Self.logger.debug("getLargestImage(for:) for comicNum=\(comicNum, privacy: .public) trying large")
            return try await getImage(for: comicNum, size: .Large)
        }
        catch ComicShopDownloadError.HTTPResponseCodeError(let responseCode) where responseCode == 404 {
            // GULP
        }

        Self.logger.debug("getLargestImage(for:) for comicNum=\(comicNum, privacy: .public) trying standard")

        // Retry with smaller image size
        return try await getImage(for: comicNum, size: .Standard)
    }

    enum ImageSize {
        case Standard
        case Large
    }
}

//MARK: - Downloads

extension ComicShop {
    enum ComicShopDownloadError: Error {
        case InvalidResponseTypeError
        case HTTPResponseCodeError(Int)
        case InvalidComicNum(Int)
    }
}

private extension ComicShop {
    static let XKCD_META_FILENAME: String = "info.0.json"
    static let XKCD_BASE_URL: URL = URL(string: "https://xkcd.com/")!
    static let XKCD_LATEST_META_URL: URL = XKCD_BASE_URL.appending(component: XKCD_META_FILENAME)

    func downloadData(from url: URL) async throws -> Data {
        let (data, response): (Data, URLResponse) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse
        else {
            throw ComicShopDownloadError.InvalidResponseTypeError
        }

        switch httpResponse.statusCode {
            case 200...299:
                // Success
                break

            default:
                throw ComicShopDownloadError.HTTPResponseCodeError(httpResponse.statusCode)
        }

        return data
    }

    func downloadAndParseMeta(for comicNum: Int? = nil) async throws -> ComicMeta {
        // By default, download the latest meta if no comic num is provided
        var metaUrl: URL = ComicShop.XKCD_LATEST_META_URL
        if let comicNum = comicNum {
            if comicNum < 1 {
                throw ComicShopDownloadError.InvalidComicNum(comicNum)
            }

            metaUrl = ComicShop.XKCD_BASE_URL.appendingPathComponent(String(comicNum)).appendingPathComponent(ComicShop.XKCD_META_FILENAME)
        }

        let data = try await downloadData(from: metaUrl)
        return try JSONDecoder().decode(ComicMeta.self, from: data)
    }
}

//MARK: - Local Filesystem

private extension ComicShop {
    static let CACHE_DIR_URL = try! FileManager.default.url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
    ).appendingPathComponent("XKCDZ")

    static let IMAGES_CACHE_DIR = CACHE_DIR_URL.appendingPathComponent("imgs")

    func ensureCacheDir() {
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: ComicShop.CACHE_DIR_URL.path, isDirectory: &isDir) {
            // TODO(Adin): Make this throw upwards instead of force trying it
            try! FileManager.default.createDirectory(at: ComicShop.CACHE_DIR_URL, withIntermediateDirectories: true)
        }
        else {
            if !isDir.boolValue {
                fatalError("Somebody stole our caches dir and made it a file!")
            }
        }
    }
}
