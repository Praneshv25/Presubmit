import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<ScannerView>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScannerView
        
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount >= 1 else {
                controller.dismiss(animated: true)
                return
            }
            
            let image = scan.imageOfPage(at: 0)
            parent.scannedImage = image
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Scanner failed with error: \(error.localizedDescription)")
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
