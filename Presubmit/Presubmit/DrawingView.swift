//
//  DrawingView.swift
//  Presubmit
//
//  Created by Pranesh Velmurugan on 2/22/25.
//

import SwiftUI

struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
}

struct DrawingView: View {
    @State private var lines: [Line] = []
    @State private var currentLine = Line(points: [])
    @State private var recognizedSymbol: String = "None"
    
    var body: some View {
        VStack {
            // Drawing canvas
            Canvas { context, _ in
                // Draw existing lines
                for line in lines {
                    var path = Path()
                    guard let firstPoint = line.points.first else { continue }
                    path.move(to: firstPoint)
                    for point in line.points.dropFirst() {
                        path.addLine(to: point)
                    }
                    context.stroke(path, with: .color(.blue), lineWidth: 3)
                }
            }
            .frame(width: 150, height: 150)
            .border(Color.gray)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newPoint = value.location
                        if currentLine.points.isEmpty {
                            currentLine.points.append(newPoint)
                        } else {
                            currentLine.points.append(newPoint)
                        }
                        // Update the lines array to show real-time drawing
                        if let lastIndex = lines.lastIndex(where: { $0.id == currentLine.id }) {
                            lines[lastIndex] = currentLine
                        } else {
                            lines.append(currentLine)
                        }
                    }
                    .onEnded { _ in
                        currentLine = Line(points: [])
                    }
            )
            
            // Display recognized symbol
            Text("Symbol: \(recognizedSymbol)")
                .font(.caption)
            
            // Clear button
            Button("Clear") {
                lines = []
                recognizedSymbol = "None"
            }
            .font(.caption)
        }
        .frame(width: 150, height: 200)
    }
}
