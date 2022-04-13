//
//  ComicListView.swift
//  XKCDZ
//
//  Created by Adin on 4/13/22.
//

import SwiftUI

struct ComicListView: View {
    @StateObject private var comicListModelView: ComicListModelView = ComicListModelView()
    
    var body: some View {
        if comicListModelView.latestComicNum == nil {
            // TODO(Adin): Make this bigger
            ProgressView()
                .task {
                    await comicListModelView.loadLatestComicNum()
                }
        }
        else {
            NavigationView {
                List {
                    ForEach((1...comicListModelView.latestComicNum!).reversed(), id: \.self) { comicNum in
                        NavigationLink {
                            ComicFullscreenView(comicNum: comicNum)
                        } label: {
                            ComicListRowView(comicNum: comicNum)
                        }
                    }
                }
                .navigationTitle("Comics")
                .navigationBarHidden(true)
            }
            .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct ComicListRowView: View {
    var comicNum: Int
    
    var body: some View {
        HStack {
            ComicImageView(comicNum: comicNum)
                .frame(width: 70, height: 70)
            
            Spacer()
            
            Text(comicNum.description)
                .font(.title)
                .bold()
            
            Spacer()
        }
    }
}

struct ComicListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicListView()
        // ComicListRowView(comicNum: 110)
    }
}
