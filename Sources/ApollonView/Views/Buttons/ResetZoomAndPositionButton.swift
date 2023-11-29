import SwiftUI

struct ResetZoomAndPositionButton: View {
    @ObservedObject var viewModel: ApollonViewViewModel

    var body: some View {
        Button {
            viewModel.setDragLocation()
            viewModel.scale = viewModel.idealScale
            viewModel.progressingScale = 1.0
        } label: {
            Image(systemName: "scope")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.blue)
                }
        }.padding([.leading, .top], 10)
    }
}
