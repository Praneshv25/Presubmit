import SwiftUI
import VisionKit
import UIKit
import GoogleSignIn
import SwiftUI
import UIKit


class DocsContainer: ObservableObject {
    @Published var docs = [ScannedDocument]()
    var fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
    }
}

struct ScannedDocument: Identifiable {
    let id = UUID()
    let images: [UIImage]
    let fileName: String
    let date: Date
}

struct CameraView: View {
    @StateObject var container = DocsContainer(fileName: "My Scans")
    @State private var showScanner = false
    @State private var scannedImages: [UIImage] = []  // Fixed variable name
    @State private var showingNameAlert = false
    @State private var documentName = ""
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: LoginViewModel
    @State private var navigateToLogin = false
    
    var body: some View {
            VStack {
                if container.docs.isEmpty {
                    Text("No scans yet")
                        .foregroundColor(.gray)
                } else {
                    List(container.docs) { doc in
                        NavigationLink(destination: DocumentCarosal(doc: doc)) {
                            HStack {
                                // Show first page as thumbnail
                                Image(uiImage: doc.images.first ?? UIImage())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 60)
                                
                                VStack(alignment: .leading) {
                                    Text(doc.fileName)
                                    Text("\(doc.images.count) pages")  // Show page count
                                    Text(doc.date, style: .date)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                
                Button("Scan Document") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showScanner = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Document Scanner")
            .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                viewModel.signOut()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.red)
                                    Text("Log Out")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedImages: $scannedImages)
                    .onDisappear {
                        if !scannedImages.isEmpty {
                            showingNameAlert = true
                        }
                    }
            }
            .alert("Name Document", isPresented: $showingNameAlert) {
                TextField("Document Name", text: $documentName)
                Button("Save") {
                    saveDocument()
                }
                Button("Cancel", role: .cancel) {
                    scannedImages.removeAll()  // Fixed cleanup
                    documentName = ""
                }
            }
        }

    
    private func saveDocument() {
        guard !scannedImages.isEmpty else { return }
        
        let newDoc = ScannedDocument(
            images: scannedImages,  // Store all images
            fileName: documentName.isEmpty ? "Scan \(Date())" : documentName,
            date: Date()
        )
        
        container.docs.append(newDoc)
        
        // Clear after saving
        scannedImages.removeAll()
        documentName = ""
    }
}

/*


struct CameraView: View {
    @State private var showScanner = false
    @State private var scannedImage: UIImage?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var container: DocsContainer = DocsContainer(fileName: "My Documents")
    @State private var isIntermediateStep = false
//    @State private var scannedDocuments: [ScannedDocument] = []
    @State private var showingNameInput = false
    @State private var documentName = ""
    
    // logout helpers
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: LoginViewModel
    @State private var navigateToLogin = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
//    @State private var container: DocsContainer = DocsContainer(fileName: "My Documents")
        
        var body: some View {
            VStack {
                if container.docs.isEmpty {
                    Text("No scanned documents")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(container.docs) { document in
                            VStack(alignment: .leading) {
                                Image(uiImage: document.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                                
                                Text(document.fileName)
                                    .font(.headline)
                                Text("Scanned on: \(document.date, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                Button("Scan Document") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showScanner = true
                    } else {
                        errorMessage = "Camera is not available"
                        showError = true
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedImage: $scannedImage)
                    .onDisappear {
                        if scannedImage != nil {
                            isIntermediateStep = true // Show intermediate step
                        }
                    }
            }
            .alert("Scan Options", isPresented: $isIntermediateStep) {
                Button("Keep Scan") {
                    showScanner = true // Continue scanning
                }
                Button("Save") {
                    showingNameInput = true // Proceed to save the document
                }
                Button("Cancel", role: .cancel) {
                    scannedImage = nil // Discard the scan
                    isIntermediateStep = false // Reset intermediate step
                }
            } message: {
                Text("Would you like to keep scanning or save this document?")
            }
            .alert("Name Your Document", isPresented: $showingNameInput) {
                TextField("Document Name", text: $documentName)
                Button("Save") {
                    if let image = scannedImage {
                        Task {
                            await saveDocument(image: image, name: documentName)
                            scannedImage = nil
                            documentName = ""
                            isIntermediateStep = false // Reset intermediate step
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    scannedImage = nil
                    documentName = ""
                    isIntermediateStep = false // Reset intermediate step
                }
            }
        }
    */
//    var body: some View {
//            VStack {
//                if container.docs.isEmpty {
//                    Text("No scanned documents")
//                        .foregroundColor(.gray)
//                } else {
//                    List {
//                        ForEach(container.docs) { document in
//                            VStack(alignment: .leading) {
//                                Image(uiImage: document.image)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxHeight: 200)
//                                    .cornerRadius(8)
//                                
//                                Text(document.fileName)
//                                    .font(.headline)
//                                Text("Scanned on: \(document.date, formatter: dateFormatter)")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                            .padding(.vertical, 8)
//                        }
//                    }
//                }
//                
//                Button("Scan Document") {
//                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                        showScanner = true
//                    } else {
//                        errorMessage = "Camera is not available"
//                        showError = true
//                    }
//                }
//                .padding()
//            }
//            .sheet(isPresented: $showScanner) {
//                ScannerView(scannedImage: $scannedImage)
//                    .onDisappear {
//                        if scannedImage != nil {
//                            showingNameInput = true
//                        }
//                    }
//            }
//            .alert("Name Your Document", isPresented: $showingNameInput) {
//                TextField("Document Name", text: $documentName)
//                Button("Save") {
//                    if let image = scannedImage {
//                        Task {
//                            await saveDocument(image: image, name: documentName)
//                            scannedImage = nil
//                            documentName = ""
//                        }
//                    }
//                }
//                Button("Cancel", role: .cancel) {
//                    scannedImage = nil
//                    documentName = ""
//                }
//            }
//        }
    /*
    var body: some View {
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
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Document Scanner")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.signOut()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.red)
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerView(scannedImage: $scannedImage)
                .onDisappear {
                    if scannedImage != nil {
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
     */
/*
    
    private func saveDocument(image: UIImage, name: String) async {
        let fileName = name.isEmpty ? "Document_\(Date())" : name
        
        // Create document object
        let document = ScannedDocument(
            image: image,
            fileName: fileName,
            date: Date(),
            mistakes: nil
        )
        //            scannedDocuments.append(document)
        container.docs.append(document)
        print("Saved")
        
        
    }*/
            /*
            guard let token = GIDSignIn.sharedInstance.currentUser?.idToken?.tokenString else {
                errorMessage = "Authentication token not found"
                showError = true
                return
            }
            
            let apiClient = ImageAPIClient(authToken: token)
            
            do {
                let processedResult = try await apiClient.processImage(image)
                // Get image dimensions
                
                let aspectRatio = image.size.height / image.size.width
                let img_width = Int(UIScreen.main.bounds.width)
                let img_height = Int(aspectRatio * UIScreen.main.bounds.width)
                
                print("Image dimensions: \(img_width) x \(img_height) pixels")
                
                // Convert API Annotations to MistakeItems
                if let index = scannedDocuments.firstIndex(where: { $0.id == document.id }) {
                    let mistakeItems = processedResult.annotations.map { annotation -> MistakeItem in
                        let box2d = annotation.box2d
                        
                        let x_min_scaled = Double(box2d[0])
                        let y_min_scaled = Double(box2d[1])
                        let x_max_scaled = Double(box2d[2])
                        let y_max_scaled = Double(box2d[3])
                        
                        let x_min = (1000.0 - x_min_scaled) * Double(img_width) / 1000.0
                        let y_min = y_min_scaled * Double(img_height) / 1000.0
                        let x_max = (1000.0 - x_max_scaled) * Double(img_width) / 1000.0
                        let y_max = y_max_scaled * Double(img_height) / 1000.0
                        
                        let centerX = (x_max + x_min) / 2.0
                        let centerY = (y_max + y_min) / 2.0
                        
                        print("Original box: \(box2d)")
                        print("Scaled coordinates: x_min: \(x_min), y_min: \(y_min), x_max: \(x_max), y_max: \(y_max)")
                        print("Center: (\(centerX), \(centerY))")
                        
                        return MistakeItem(
                            text: annotation.text,
                            box_2d: [Int(centerX), Int(centerY)],
                            mistakes: annotation.mistakes.isEmpty ? annotation.text : annotation.mistakes
                        )
                    }
                    scannedDocuments[index].mistakes = mistakeItems
                }
            } catch {
                // Remove the document from the array if API processing failed
                if let index = scannedDocuments.firstIndex(where: { $0.id == document.id }) {
                    scannedDocuments.remove(at: index)
                }
                
                errorMessage = "Failed to process document: \(error.localizedDescription)"
                showError = true
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
             */
//}
