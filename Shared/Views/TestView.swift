//
//  TestView.swift
//  XKCDZ
//
//  Created by Adin on 4/18/22.
//

import SwiftUI

struct TestView: View {
    @StateObject var listMV: ComicListModelView = ComicListModelView()
    
    var body: some View {
        if listMV.latestComicNum == nil {
            ProgressView()
                .task {
                    await listMV.loadLatestComicNum()
                }
        }
        else {
            ScrollView {
                HStack {
                    VStack {
                        ForEach((1...listMV.latestComicNum!).reversed().filter({ $0 % 2 == 0 }), id: \.self) { comicNum in
                            Spacer()
                            
                            ComicImageView(comicNum: comicNum)
                            
                            Spacer()
                        }
                    }
                        
                    VStack {
                        ForEach((1...listMV.latestComicNum!).reversed().filter({ $0 % 2 != 0 }), id: \.self) { comicNum in
                            Spacer()
                            
                            ComicImageView(comicNum: comicNum)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .preferredColorScheme(.dark)
    }
}
