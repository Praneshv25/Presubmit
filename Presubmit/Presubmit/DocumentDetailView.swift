import SwiftUI

func convert_coord(x: Int, y: Int, image: UIImage) -> CGPoint {
    let w = UIScreen.main.bounds.width
    let h = w * CGFloat(image.size.height) / CGFloat(image.size.width)

    var new_x = CGFloat(1000 - x) / 1000.0 * w
    var new_y = CGFloat(y) / 1000.0 * h
    
    return CGPoint(x: new_x, y: new_y)
}

struct DocumentDetailView: View {
    let document: ScannedDocument
    @State private var selectedMistake: UUID? = nil
    
    // Size of the popup
    private let popupWidth: CGFloat = 300
    private let popupHeight: CGFloat = 100 // Approximate height, adjust as needed
    
    func clampedPosition(for point: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        var newX = point.x
        var newY = point.y
        
        // Ensure popup stays within horizontal bounds
        if newX + popupWidth/2 > geometry.size.width {
            newX = geometry.size.width - popupWidth/2
        } else if newX - popupWidth/2 < 0 {
            newX = popupWidth/2
        }
        
        // Ensure popup stays within vertical bounds
        if newY + popupHeight/2 > geometry.size.height {
            newY = geometry.size.height - popupHeight/2
        } else if newY - popupHeight/2 < 0 {
            newY = popupHeight/2
        }
        
        return CGPoint(x: newX, y: newY)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full screen image
                Image(uiImage: document.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                
                // Circles for mistakes
                ForEach(document.mistakes.indices) { i in
                    if (document.mistakes[i].mistakes != "") {
                        Circle()
                            .fill(Color.red.opacity(0.6))
                            .frame(width: 50, height: 50)
                            .position(
                                convert_coord(x: document.mistakes[i].box_2d[0], y: document.mistakes[i].box_2d[1], image: document.image)
                            )
                            .onTapGesture {
                                selectedMistake = document.mistakes[i].id
                            }
                    }
                }
                
                // Popup overlay
                if let selectedId = selectedMistake,
                   let selectedMistakeIndex = document.mistakes.firstIndex(where: { $0.id == selectedId }) {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.selectedMistake = nil
                        }
                    
                    VStack {
                        Text(document.mistakes[selectedMistakeIndex].mistakes)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .frame(maxWidth: popupWidth)
                    .position(
                        clampedPosition(
                            for: convert_coord(
                                x: document.mistakes[selectedMistakeIndex].box_2d[0],
                                y: document.mistakes[selectedMistakeIndex].box_2d[1],
                                image: document.image
                            ),
                            in: geometry
                        )
                    )
                }
            }
        }
        .navigationTitle(document.fileName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
