import SwiftUI
import VisionKit
import UIKit
import FirebaseAuth

struct ScannedDocument: Identifiable {
    let id = UUID()
    var image: UIImage
    var fileName: String
    var date: Date
    var mistakes: [MistakeItem]?
}

struct CameraView: View {
    @State private var showScanner = false
    @State private var scannedImage: UIImage?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var scannedDocuments: [ScannedDocument] = []
    @State private var showingNameInput = false
    @State private var documentName = ""
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if scannedDocuments.isEmpty {
                    Text("No scanned documents")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(scannedDocuments) { document in
                            NavigationLink(destination: DocumentDetailView(document: document)) {
                                VStack(alignment: .leading) {
                                    Image(uiImage: document.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                        .cornerRadius(8)
                                    
                                    Text(document.fileName)
                                        .font(.headline)
                                    Text("Scanned on: \(dateFormatter.string(from: document.date))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .onDelete(perform: deleteDocuments)
                    }
                }
                
                Button(action: {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showScanner = true
                    } else {
                        errorMessage = "Camera is not available"
                        showError = true
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.viewfinder")
                        Text("Scan Document")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Document Scanner")
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedImage: $scannedImage)
                    .onDisappear {
                        if let image = scannedImage {
                            showingNameInput = true
                        }
                    }
            }
            .alert("Name Your Document", isPresented: $showingNameInput) {
                TextField("Document Name", text: $documentName)
                Button("Save") {
                    if let image = scannedImage {
                        Task {
                            await saveDocument(image: image, name: documentName)
                            scannedImage = nil
                            documentName = ""
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    scannedImage = nil
                    documentName = ""
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveDocument(image: UIImage, name: String) async {
            print("here")
            let fileName = name.isEmpty ? "Document_\(Date())" : name
            
            // Create document object
            let document = ScannedDocument(
                image: image,
                fileName: fileName,
                date: Date(),
                mistakes: nil
            )
            scannedDocuments.append(document)
            
            // Save locally and upload
            if let data = image.jpegData(compressionQuality: 0.5) {
                
                do {
                    let base64String = data.base64EncodedString()
                    
//                    print(base64String)
                    
//                    print("Base64 string length: \(base64String.count)")
                    
                    // Create upload URL request
                    guard let url = URL(string: "http://128.210.107.131:5000/api/process-image") else {
                        print("Invalid URL")
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    // Add Authorization header
                    guard let id_token = try await Auth.auth().currentUser?.getIDToken() else { return }

                    request.setValue("Bearer \(id_token)", forHTTPHeaderField: "Authorization")
                        
                    // Create JSON payload
                    let payload: [String: Any] = [
                        "image": base64String,
                        "symbols": []
                    ]
                    
                    request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
                    
                    // Send request
                    do {
                        let (responseData, response) = try await URLSession.shared.data(for: request)
                        
                        
                        // Print response body for debugging
                        if let responseString = String(data: responseData, encoding: .utf8) {
                            print("Response body: \(responseString)")
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            print("Upload status code: \(httpResponse.statusCode)")
                            if httpResponse.statusCode != 200 {
                                await MainActor.run {
                                    errorMessage = "Upload failed with status: \(httpResponse.statusCode)"
                                    showError = true
                                }
                            }
                        }
                    } catch {
                        print("Upload error: \(error)")
                        await MainActor.run {
                            errorMessage = "Upload failed: \(error.localizedDescription)"
                            showError = true
                        }
                    }
                    
                } catch {
                    print("Error saving file: \(error)")
                    errorMessage = "Failed to save document"
                    showError = true
                }
            }
        }
    
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            let document = scannedDocuments[index]
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("\(document.fileName).jpg")
            
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        
        scannedDocuments.remove(atOffsets: offsets)
    }
}
