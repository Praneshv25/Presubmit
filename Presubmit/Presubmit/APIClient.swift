//
//  APIClient.swift
//  Presubmit
//
//  Created by Vincent Zhao on 2/22/25.
//
import UIKit
import Foundation


struct Annotation: Codable {
    let text: String
    let box2d: [Int]
    let mistakes: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case box2d = "box_2d"
        case mistakes
    }
}

struct ProcessImageResponse: Codable {
    let annotations: [Annotation]
    let symbol: String?
}

let jsonData = """
{
    "symbol": "star",
    "annotations": [
        { 
            "text": "(0,2) (2,4)", 
            "box_2d": [367, 75, 430, 124], 
            "mistakes": "" 
        },
        { 
            "text": "y = mx + b", 
            "box_2d": [687, 96, 777, 135], 
            "mistakes": "" 
        },
        { 
            "text": "m = (4-2)/(2-0) = 2/2 = 2", 
            "box_2d": [480, 104, 713, 214], 
            "mistakes": "The slope calculation is incorrect. It should be m = (4-2)/(2-0) = 2/2 = 1, not 2" 
        },
        { 
            "text": "2 = 2 * 0 + b", 
            "box_2d": [711, 104, 773, 215], 
            "mistakes": "Used the incorrect slope value from the previous calculation. Should be 2 = 1 * 0 + b" 
        },
        { 
            "text": "b=2", 
            "box_2d": [773, 105, 836, 143], 
            "mistakes": "" 
        },
        { 
            "text": "Section 1 [xmn, #2NQA]", 
            "box_2d": [589, 487, 863, 516], 
            "mistakes": "" 
        }
    ]
}
""".data(using: .utf8)!

enum ImageProcessingError: Error {
    case invalidImage
    case networkError(Error)
    case invalidResponse
    case authenticationError
    case serverError(String)
}
class ImageAPIClient {
    private let baseURL = "https://presubmit-api-1001307482976.us-central1.run.app"
    private let session: URLSession
    private let authToken: String
    
    init(authToken: String, session: URLSession = .shared) {
        self.authToken = authToken
        self.session = session
    }
    
    func processImage(_ image: UIImage, symbols: [String] = []) async throws -> ProcessImageResponse {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw ImageProcessingError.invalidImage
        }
        
        // Convert image data to base64
        let base64Image = imageData.base64EncodedString()
        
        print(base64Image.count)
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "image": base64Image,
            "symbols": symbols
        ]
        
        // Create URL
        guard let url = URL(string: "\(baseURL)/api/process-image") else {
            throw ImageProcessingError.invalidResponse
        }
        
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw ImageProcessingError.invalidResponse
//            }
            
//            switch httpResponse.statusCode {
            switch 200 {
            case 200:
                print("200")
                let decoder = JSONDecoder()
                return try decoder.decode(ProcessImageResponse.self, from: jsonData)
//                return try decoder.decode(ProcessImageResponse.self, from: data)
            case 401:
                print("401")
                throw ImageProcessingError.authenticationError
            case 500:
                print("500")

                let errorResponse = try JSONDecoder().decode([String: String].self, from: data)
                throw ImageProcessingError.serverError(errorResponse["details"] ?? "Unknown server error")
            default:
                print("invalid response")
                throw ImageProcessingError.invalidResponse
            }
        } catch {
            print("weirdo")
            throw ImageProcessingError.networkError(error)
        }
    }
}
