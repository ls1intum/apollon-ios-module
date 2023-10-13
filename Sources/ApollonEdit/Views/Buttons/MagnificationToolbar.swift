import SwiftUI

struct MagnificationToolbar: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            // Zoom Out Button
            Button {
                if viewModel.scale >= viewModel.minScale + 0.1 {
                    viewModel.scale -= 0.1
                }
            } label: {
                Image(systemName: "minus.magnifyingglass")
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
                    .padding(5)
            }
            
            // Zoom In Button
            Button {
                if viewModel.scale <= viewModel.maxScale - 0.1 {
                    viewModel.scale += 0.1
                }
            } label: {
                Image(systemName: "plus.magnifyingglass")
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
                    .padding(5)
            }
            
            Divider()
                .frame(width: 1, height: 20)
                .overlay(.white)
            
            // Reset Zoom and Position button
            Button {
                viewModel.setDragLocation()
                viewModel.scale = viewModel.minScale
                viewModel.progressingScale = 1.0
            } label: {
                Image(systemName: "scope")
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
                    .padding(5)
            }
        }
        .frame(height: 30)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.blue)
        }
    }
}
