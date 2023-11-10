import SwiftUI

struct ResetZoomAndPositionButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        Button {
            viewModel.setDragLocation()
            viewModel.scale = viewModel.idealScale
            viewModel.progressingScale = 1.0
        } label: {
            Image(systemName: "scope")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.blue)
                }
        }.padding([.leading, .top], 10)
    }
}
