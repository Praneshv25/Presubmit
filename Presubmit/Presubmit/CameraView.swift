import SwiftUI
import VisionKit
import UIKit
import GoogleSignIn

struct SymbolFolderMapping: Identifiable, Codable {
    let id: UUID
    var symbol: String
    var folderName: String
    
    init(id: UUID = UUID(), symbol: String, folderName: String) {
        self.id = id
        self.symbol = symbol
        self.folderName = folderName
    }
}

class SymbolMappingManager {
    static let shared = SymbolMappingManager()
    private let defaults = UserDefaults.standard
    private let mappingsKey = "symbolFolderMappings"
    
    private init() {}
    
    func saveMappings(_ mappings: [SymbolFolderMapping]) {
        do {
            let data = try JSONEncoder().encode(mappings)
            defaults.set(data, forKey: mappingsKey)
        } catch {
            print("Error saving mappings: \(error)")
        }
    }
    
    func loadMappings() -> [SymbolFolderMapping] {
        guard let data = defaults.data(forKey: mappingsKey) else {
            // Return default mappings if none exist
            return [
                SymbolFolderMapping(symbol: "📚", folderName: "Books"),
                SymbolFolderMapping(symbol: "📄", folderName: "Documents"),
                SymbolFolderMapping(symbol: "📝", folderName: "Notes")
            ]
        }
        
        do {
            return try JSONDecoder().decode([SymbolFolderMapping].self, from: data)
        } catch {
            print("Error loading mappings: \(error)")
            return []
        }
    }
}
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
    var images: [UIImage]
    var mistakes: [[MistakeItem]]
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
                        NavigationLink(destination: DocumentDetailView(document: doc)) {
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
                    Task {
                        await saveDocument()
                    }
                }
                Button("Cancel", role: .cancel) {
                    scannedImages.removeAll()  // Fixed cleanup
                    documentName = ""
                }
            }
        }

    
    private func saveDocument() async {
        guard !scannedImages.isEmpty else { return }
        
        var newDoc = ScannedDocument(
            images: scannedImages,  // Store all images
            mistakes: [],
            fileName: documentName.isEmpty ? "Scan \(Date())" : documentName,
            date: Date()
        )
        
        guard let token = GIDSignIn.sharedInstance.currentUser?.idToken?.tokenString else {
            return
        }
        
        let apiClient = ImageAPIClient(authToken: token)
        do {
            let res = try await apiClient.processImagesConcurrently(scannedImages, symbols: ["star", "square"])
            
            print(res)
        
            newDoc.mistakes = res.map { response in
                return response.annotations.map { annotation in
                    return MistakeItem(text: annotation.text, box_2d: [annotation.box2d[0], annotation.box2d[1]], mistakes: annotation.mistakes)
                }
            }
        } catch {
            print("error")
        }
        
        container.docs.append(newDoc)
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            let document = container.docs[index]
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("\(document.fileName).jpg")
            
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        
        container.docs.remove(atOffsets: offsets)
        
        // Clear after saving
        scannedImages.removeAll()
        documentName = ""
    }
}
