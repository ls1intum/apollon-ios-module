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
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .padding(5)
            }
            
            Divider()
                .frame(width: 1)
                .frame(maxHeight: 30)
                .overlay(.white)
                .padding(5)
            
            // Reset Zoom and Position button
            Button {
                viewModel.setDragLocation()
                viewModel.scale = viewModel.idealScale
                viewModel.progressingScale = 1.0
            } label: {
                Image(systemName: "scope")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .padding(5)
            }
        }.background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.blue)
        }.frame(maxWidth: 125, maxHeight: 30)
            .padding(3)
    }
}
