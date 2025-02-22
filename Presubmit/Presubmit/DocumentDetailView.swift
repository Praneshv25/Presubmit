//
//  DocumentDetailView.swift
//  Presubmit
//
//  Created by Pranesh Velmurugan on 2/22/25.
//

import SwiftUI

struct DocumentDetailView: View {
    let document: ScannedDocument
    @State private var selectedMistake: UUID? = nil
    
    var body: some View {
        ZStack {
            // Full screen image
            Image(uiImage: document.image)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
            
            // Overlay mistakes if they exist
            if let mistakes = document.mistakes {
                ForEach(mistakes) { mistake in
                    if !mistake.mistakes.isEmpty {
                        MistakeOverlay(
                            item: mistake,
                            isSelected: selectedMistake == mistake.id,
                            onTap: {
                                withAnimation {
                                    selectedMistake = selectedMistake == mistake.id ? nil : mistake.id
                                }
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle(document.fileName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
