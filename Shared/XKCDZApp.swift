//
//  XKCDZApp.swift
//  Shared
//
//  Created by Adin on 4/12/22.
//

import SwiftUI

@main
struct XKCDZApp: App {
    var comicStore: ComicStore = ComicStore()
    
    var body: some Scene {
        WindowGroup {
            ComicListView()
        }
    }
}
