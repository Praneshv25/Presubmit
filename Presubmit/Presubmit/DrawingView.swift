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
                        recognizeSymbol()
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
    
    private func recognizeSymbol() {
        guard let points = lines.last?.points, !points.isEmpty else { return }
        
        let xCoordinates = points.map { $0.x }
        let yCoordinates = points.map { $0.y }
        let minX = xCoordinates.min() ?? 0
        let maxX = xCoordinates.max() ?? 0
        let minY = yCoordinates.min() ?? 0
        let maxY = yCoordinates.max() ?? 0
        
        let width = maxX - minX
        let height = maxY - minY
        
        // Print debugging information
        print("Width: \(width)")
        print("Height: \(height)")
        print("Number of points: \(points.count)")
        
        // Simple aspect ratio check
        let aspectRatio = width / height
        print("Aspect ratio: \(aspectRatio)")
        
        if aspectRatio > 0.8 && aspectRatio < 1.2 {
            recognizedSymbol = "Square/Circle"
        } else if width > height {
            recognizedSymbol = "Horizontal"
        } else {
            recognizedSymbol = "Vertical"
        }
        
        print("Recognized as: \(recognizedSymbol)")
    }
}
