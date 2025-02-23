import SwiftUI

struct MistakeView: View {
    @State private var selectedMistake: UUID? = nil
    @Binding var mistakes: [MistakeItem]
    @Binding var documentImage: UIImage
    let geometry: GeometryProxy

    // Size of the popup
    private let popupWidth: CGFloat = 300
    private let popupHeight: CGFloat = 100 // Adjust as needed
    

    func clampedPosition(for point: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        var newX = point.x
        var newY = point.y

        // Ensure popup stays within horizontal bounds
        if newX + popupWidth / 2 > geometry.size.width {
            newX = geometry.size.width - popupWidth / 2
        } else if newX - popupWidth / 2 < 0 {
            newX = popupWidth / 2
        }

        // Ensure popup stays within vertical bounds
        if newY + popupHeight / 2 > geometry.size.height {
            newY = geometry.size.height - popupHeight / 2
        } else if newY - popupHeight / 2 < 0 {
            newY = popupHeight / 2
        }

        return CGPoint(x: newX, y: newY)
    }

    func convert_coord(x: CGFloat, y: CGFloat, image: UIImage) -> CGPoint {
        let w = geometry.size.width//UIScreen.main.bounds.width
        let h = w * CGFloat(image.size.height) / CGFloat(image.size.width)

        let new_x = CGFloat(1000 - x) / 1000.0 * w
        let new_y = CGFloat(y) / 1000.0 * h
        
        print((new_x, new_y))
        
        return CGPoint(x: new_x, y: new_y)
    }

    var body: some View {
        ZStack {
            ForEach(mistakes.indices, id: \.self) { i in
                if !mistakes[i].mistakes.isEmpty {
                    Circle()
                        .fill(Color.red.opacity(0.6))
                        .frame(width: 50, height: 50)
                        .position(
                            convert_coord(x: CGFloat(mistakes[i].box_2d[0]), y: CGFloat(mistakes[i].box_2d[1]), image: documentImage)
                        )
                        .onTapGesture {
                            selectedMistake = mistakes[i].id
                        }
                }
            }

            // Popup overlay
            if let selectedId = selectedMistake,
               let selectedMistakeIndex = mistakes.firstIndex(where: { $0.id == selectedId }) {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.selectedMistake = nil
                    }

                VStack {
                    Text(mistakes[selectedMistakeIndex].mistakes)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .frame(width: popupWidth)
                .position(
                    clampedPosition(
                        for: convert_coord(
                            x: CGFloat(mistakes[selectedMistakeIndex].box_2d[0]),
                            y: CGFloat(mistakes[selectedMistakeIndex].box_2d[1]),
                            image: documentImage
                        ),
                        in: geometry
                    )
                )
            }
        }
    }
}


struct DocumentDetailView: View {
    @State var document: ScannedDocument
    @State private var currentPage = 0
    
    
    var body: some View {
        // Full screen image
        GeometryReader { geometry in
            ZStack {
                VStack {
                    
                    TabView(selection: $currentPage) {
                        ForEach(0..<document.images.count, id: \.self) { index in
                            Image(uiImage: document.images[index])
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    Text("Page \(currentPage + 1) of \(document.images.count)")
                        .font(.caption)
                        .padding()
                    
                    Text(document.fileName)
                        .font(.title)
                    Text("Scanned: \(document.date.formatted())")
                        .foregroundColor(.gray)
                }
                .padding()
                .navigationBarBackButtonHidden(false)
                
                MistakeView(
                    mistakes: $document.mistakes[currentPage],
                    documentImage: $document.images[currentPage],
                    geometry: geometry
                )
            }
            
        }
        .navigationTitle(document.fileName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
