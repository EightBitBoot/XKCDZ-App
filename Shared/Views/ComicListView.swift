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
                VStack{
                    HStack {
                        Spacer()
                        
                        Text("XKCD")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                    }
                        
                    List {
                        ForEach((1...comicListModelView.latestComicNum!).reversed(), id: \.self) { comicNum in
                            NavigationLink {
                                ComicFullscreenView(comicNum: comicNum)
                            } label: {
                                ComicListRowView(comicNum: comicNum)
                            }
                        }
                    }
                    .refreshable {
                        await comicListModelView.refresh()
                    }
                }
                .navigationTitle("Comics")
                .navigationBarHidden(true)
            }
        }
    }
}

struct ComicListRowView: View {
    @StateObject var comicMetadataModelView: ComicMetadataModelView = ComicMetadataModelView()
    var comicNum: Int
    
    var body: some View {
        HStack {
            ComicImageView(comicNum: comicNum)
                .frame(width: 70, height: 70)
            
            if comicMetadataModelView.comicMetadata == nil {
                // Only center when displaying just the number
                Spacer()
            
                Text(comicNum.description)
                    .font(.title3)
                    .bold()
                    .task {
                        await comicMetadataModelView.load(comicNum)
                    }
            }
            else {
                withAnimation {
                    Text("\(comicNum.description) - \(comicMetadataModelView.comicMetadata!.safe_title)")
                        .font(.title3)
                        .bold()
                }
            }
            
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
