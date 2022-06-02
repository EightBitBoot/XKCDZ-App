//
//  DirExplorerView.swift
//  XKCDZ
//
//  Created by Adin on 5/31/22.
//

import SwiftUI

struct DirectoryExplorerView: View {
    @State private var isLoading = true
    @State private var rootNode: INode
    
    init(rootUrl: URL) {
        self.rootNode = INode(url: rootUrl)
    }
    
    var body: some View {
        if isLoading {
            VStack(spacing: 10) {
                Text("Loading File Tree")
                ProgressView()
            }
            .task {
                await Task {
                    parseFileTree(rootNode: rootNode)
                }.value
                
                isLoading = false
            }
        }
        else {
            NavigationView {
                List([rootNode], children: \.children) { listItem in
                    DirectoryExplorerListRowView(node: listItem)
                }
            }
        }
    }
    
    func parseFileTree(rootNode: INode) {
        if !((try? rootNode.url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false) {
            return
        }
        
        let dirContents = (try? FileManager.default.contentsOfDirectory(at: rootNode.url, includingPropertiesForKeys: [.isDirectoryKey])
            .sorted { (leftUrl, rightUrl) -> Bool in
                let leftName = leftUrl.lastPathComponent
                let rightName = rightUrl.lastPathComponent
                if let leftNum = Int(leftName),
                   let rightNum = Int(rightName)
                {
                    // Reverse only numbers, not strings
                    return leftNum > rightNum
                }
                
                return leftName.compare(rightName) != .orderedDescending // !(leftName > rightName)
            }) ?? []
        for childUrl in dirContents {
            let newNode = INode(url: childUrl)
            
            if rootNode.children == nil {
                rootNode.children = [newNode]
            }
            else {
                rootNode.children!.append(newNode)
            }
            
            parseFileTree(rootNode: newNode)
        }
    }
}

struct DirectoryExplorerListRowView: View {
    let node: INode
    
    var body: some View {
        if node.url.pathExtension == "png" || node.url.pathExtension == "jpg" {
            NavigationLink {
                DiskImageView(imageUrl: node.url)
            } label: {
                Text(node.name)
            }
        }
        else {
            Text(node.name)
        }
    }
}

struct DiskImageView: View {
    let imageUrl: URL
    
    var body: some View {
        Group {
            if let uiImage = UIImage(contentsOfFile: imageUrl.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            else {
                Image(systemName: "xmark.octagon")
                    .foregroundColor(.red)
            }
        }
    }
}

class INode: Identifiable {
    let id: UUID = UUID()
    
    let url: URL
    let isDir: Bool
    
    var children: [INode]? = nil
    
    init(url: URL) {
        self.url = url
        self.isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
    }
    
    var name: String {
        url.lastPathComponent
    }
}

struct CacheDirExplorer_Previews: PreviewProvider {
    static var previews: some View {
        let rootUrl = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        DirectoryExplorerView(rootUrl: rootUrl)
            .preferredColorScheme(.dark)
    }
}
