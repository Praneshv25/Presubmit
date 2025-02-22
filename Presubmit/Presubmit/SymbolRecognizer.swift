//
//  SymbolRecognizer.swift
//  Presubmit
//
//  Created by Pranesh Velmurugan on 2/22/25.
//

import Foundation
import CoreGraphics

class SymbolRecognizer {
    static func recognizeSymbol(from points: [CGPoint]) -> String? {
        // Simplified recognition based on basic geometry
        guard points.count >= 3 else { return nil }
        
        // Calculate bounding box
        let xCoordinates = points.map { $0.x }
        let yCoordinates = points.map { $0.y }
        let minX = xCoordinates.min() ?? 0
        let maxX = xCoordinates.max() ?? 0
        let minY = yCoordinates.min() ?? 0
        let maxY = yCoordinates.max() ?? 0
        
        let width = maxX - minX
        let height = maxY - minY
        
        // Check if it's roughly square
        let aspectRatio = width / height
        if aspectRatio > 0.8 && aspectRatio < 1.2 {
            return "square"
        }
        
        // Check if it's roughly circular
        let pathLength = calculatePathLength(points: points)
        let boundingBoxPerimeter = 2 * (width + height)
        let circularityRatio = pathLength / boundingBoxPerimeter
        if circularityRatio > 0.785 && circularityRatio < 1.215 {
            return "circle"
        }
        
        // If neither square nor circle, assume triangle
        return "triangle"
    }
    
    private static func calculatePathLength(points: [CGPoint]) -> CGFloat {
        var length: CGFloat = 0
        for i in 0..<points.count-1 {
            let dx = points[i+1].x - points[i].x
            let dy = points[i+1].y - points[i].y
            length += sqrt(dx*dx + dy*dy)
        }
        return length
    }
}
