//
//  DocumentDetailView.swift
//  Presubmit
//
//  Created by Pranesh Velmurugan on 2/22/25.
//
import SwiftUI

struct DocumentCarosal: View {
    let doc: ScannedDocument
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<doc.images.count, id: \.self) { index in
                    Image(uiImage: doc.images[index])
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            
            Text("Page \(currentPage + 1) of \(doc.images.count)")
                .font(.caption)
                .padding()
            
            Text(doc.fileName)
                .font(.title)
            Text("Scanned: \(doc.date.formatted())")
                .foregroundColor(.gray)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
