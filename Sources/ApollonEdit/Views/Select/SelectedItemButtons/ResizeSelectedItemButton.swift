import SwiftUI
import ApollonShared

struct ResizeSelectedItemButton: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    var resizeBy: ResizeableDirection

    var body: some View {
        Group {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(15)
                .background(resizeBy == .none ? .gray : viewModel.themeColor)
                .clipShape(Circle())
                .disabled(resizeBy == .none)
        }
        .frame(width: 50, height: 50)
    }
}
