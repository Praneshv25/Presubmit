//
//  MistakeOverlay.swift
//  Presubmit
//
//  Created by Pranesh Velmurugan on 2/22/25.
//

import SwiftUI

struct MistakeOverlay: View {
    let item: MistakeItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        let box = item.box_2d
        
        ZStack(alignment: .center) {
            // Red dot
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(x: CGFloat(box[0]), y: CGFloat(box[1]))
                .onTapGesture(perform: onTap)
            
            // Tooltip
            if isSelected {
                Text(item.mistakes)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .frame(maxWidth: 200)
                    .position(x: CGFloat(box[0] + 100),
                            y: CGFloat(box[1]))
                    .transition(.opacity)
            }
        }
    }
}
