import SwiftUI
import VisionKit
import UIKit

struct ScannedDocument: Identifiable {
    let id = UUID()
    var image: UIImage
    var fileName: String
    var date: Date
}

struct ContentView: View {
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
                        saveDocument(image: image, name: documentName)
                        scannedImage = nil
                        documentName = ""
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
    
    private func saveDocument(image: UIImage, name: String) {
        // Create document object
        let fileName = name.isEmpty ? "Document_\(Date())" : name
        let document = ScannedDocument(image: image, fileName: fileName, date: Date())
        scannedDocuments.append(document)
        
        // Save to local storage
        if let data = image.jpegData(compressionQuality: 0.8) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("\(fileName).jpg")
            
            do {
                try data.write(to: fileURL)
                print("File saved successfully at: \(fileURL)")
            } catch {
                print("Error saving file: \(error)")
                errorMessage = "Failed to save document"
                showError = true
            }
        }
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        // Delete from local storage
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
        
        // Delete from array
        scannedDocuments.remove(atOffsets: offsets)
    }
}
