import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedImages: [UIImage] // Change to array
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: ScannerView
        
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // Capture all pages
            var images = [UIImage]()
            for pageIndex in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: pageIndex))
            }
            
            parent.scannedImages = images
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scanner error: \(error.localizedDescription)")
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
