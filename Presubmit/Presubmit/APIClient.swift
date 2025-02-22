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
}

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
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageProcessingError.invalidImage
        }
        
        // Convert image data to base64
        let base64Image = imageData.base64EncodedString()
        
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageProcessingError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                print("200")
                let decoder = JSONDecoder()
                return try decoder.decode(ProcessImageResponse.self, from: data)
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
