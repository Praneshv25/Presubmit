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

struct ScannedDocument: Identifiable {
    let id: UUID = UUID()
    var image: UIImage
    var fileName: String
    var date: Date
    var mistakes: [MistakeItem]
}

struct CameraView: View {
    @State private var showScanner = false
    @State private var scannedImage: UIImage?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var scannedDocuments: [ScannedDocument] = []
    @State private var showingNameInput = false
    @State private var documentName = ""
    @State private var showSymbolSheet = false
    @State private var symbolMappings: [SymbolFolderMapping] = []
    @State private var editingMapping: SymbolFolderMapping?
    @State private var tempFolderName: String = ""
    
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
    
    var body: some View {
        ZStack {
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
            
            // Floating Action Button for Symbol Folders
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        showSymbolSheet = true
                    }) {
                        Image(systemName: "folder.badge.gearshape")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
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
        .onAppear {
            // Load saved mappings when view appears
            symbolMappings = SymbolMappingManager.shared.loadMappings()
        }
        .sheet(isPresented: $showScanner) {
            ScannerView(scannedImage: $scannedImage)
                .onDisappear {
                    if scannedImage != nil {
                        showingNameInput = true
                    }
                }
        }
        .sheet(isPresented: $showSymbolSheet) {
            NavigationView {
                List {
                    ForEach(symbolMappings) { mapping in
                        HStack {
                            Text(mapping.symbol)
                                .font(.title2)
                            Text(mapping.folderName)
                            Spacer()
                            Button(action: {
                                editingMapping = mapping
                                tempFolderName = mapping.folderName
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteSymbolMapping)
                    
                    Button(action: {
                        let newMapping = SymbolFolderMapping(symbol: "📁", folderName: "New Folder")
                        symbolMappings.append(newMapping)
                        SymbolMappingManager.shared.saveMappings(symbolMappings)
                        editingMapping = newMapping
                        tempFolderName = newMapping.folderName
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Mapping")
                        }
                    }
                }
                .navigationTitle("Symbol Folders")
                .navigationBarItems(trailing: Button("Done") {
                    showSymbolSheet = false
                })
            }
            .alert("Edit Folder Name", isPresented: .init(
                get: { editingMapping != nil },
                set: { if !$0 { editingMapping = nil } }
            )) {
                TextField("Folder Name", text: $tempFolderName)
                Button("Save") {
                    if let index = symbolMappings.firstIndex(where: { $0.id == editingMapping?.id }) {
                        symbolMappings[index].folderName = tempFolderName
                        SymbolMappingManager.shared.saveMappings(symbolMappings)
                    }
                    editingMapping = nil
                }
                Button("Cancel", role: .cancel) {
                    editingMapping = nil
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
    
    private func saveDocument(image: UIImage, name: String) async {
        print("here")
        let fileName = name.isEmpty ? "Document_\(Date())" : name
        
        // Create document object
        
        
        guard let token = GIDSignIn.sharedInstance.currentUser?.idToken?.tokenString else {
            return
        }
        
        let apiClient = ImageAPIClient(authToken: token)
        do {
            let res = try await apiClient.processImage(image)
            
            var document = ScannedDocument(
                image: image,
                fileName: fileName,
                date: Date(),
                mistakes: []
            )
            
            document.mistakes = res.annotations.map { annotation in
                return MistakeItem(text: annotation.text, box_2d: [annotation.box2d[0], annotation.box2d[1]], mistakes: annotation.mistakes)
            }
            
            scannedDocuments.append(document)
        } catch {
            print("error")
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
    
    private func deleteSymbolMapping(at offsets: IndexSet) {
        symbolMappings.remove(atOffsets: offsets)
        SymbolMappingManager.shared.saveMappings(symbolMappings)
    }
}
