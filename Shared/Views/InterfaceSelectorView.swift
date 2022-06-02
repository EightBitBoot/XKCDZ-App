//
//  InterfaceSelectorView.swift
//  XKCDZ
//
//  Created by Adin on 5/31/22.
//

import SwiftUI

struct InterfaceSelectorView: View {
    var body: some View {
        NavigationView {
            Group {
                HStack(spacing: 30) {
                    NavigationLink {
                        ComicListView()
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("List View")
                    }

                    NavigationLink {
                        UIComicCollectionViewControllerRepresentable()
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("Collection View")
                    }
                    
                    NavigationLink {
                        DirectoryExplorerView(rootUrl: ComicImageDatabase.shared.imgCacheUrl)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                       Text("Cache Dir Explorer")
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationTitle("Interface Selection")
        }
    }
}

struct InterfaceSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        InterfaceSelectorView()
            .preferredColorScheme(.dark)
    }
}
