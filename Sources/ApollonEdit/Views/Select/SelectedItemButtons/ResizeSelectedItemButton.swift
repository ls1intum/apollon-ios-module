import SwiftUI
import ApollonShared

struct ResizeSelectedItemButton: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    var resizeBy: ResizeableDirection

    var body: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .frame(width: 35, height: 35)
            .foregroundColor(.white)
            .padding(5)
            .background {
                Circle()
                    .foregroundColor(resizeBy == .none ? .gray : .blue)
            }
            .disabled(resizeBy == .none)
    }
}
