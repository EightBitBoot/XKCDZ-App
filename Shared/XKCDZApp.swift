//
//  XKCDZApp.swift
//  Shared
//
//  Created by Adin on 4/12/22.
//

import SwiftUI

@main
struct XKCDZApp: App {
    var body: some Scene {
        WindowGroup {
            ComicListChoiceView()
        }
    }
}

struct ComicListChoiceView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                HStack(spacing: 15) {
                    NavigationLink {
                        ComicListView()
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("List View")
                    }

                    Spacer()
                        .frame(width: 30)

                    NavigationLink {
                        UIComicCollectionViewControllerRepresentable()
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("Collection View")
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .navigationTitle("Interface Selection")
        }
    }
}
