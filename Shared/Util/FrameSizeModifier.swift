//
//  ShowFrameBordersModifier.swift
//  XKCDZ (iOS)
//
//  Created by Adin on 5/12/22.
//

import SwiftUI

extension View {
    func showFrameSize() -> some View {
        return modifier(FrameSize())
    }
}

struct FrameSize: ViewModifier {
    static let borderColor: Color = .gray
    static let textColor: Color = .blue
    
    func body(content: Content) -> some View {
        return content.overlay(GeometryReader(content: overlay(for:)))
    }
    
    func overlay(for geometryProxy: GeometryProxy) -> some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            Rectangle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundColor(FrameSize.borderColor)
            
            Text("\(Int(geometryProxy.size.width))x\(Int(geometryProxy.size.height))")
                .font(.caption2)
                .foregroundColor(FrameSize.textColor)
                .padding(2)
        }
    }
}
