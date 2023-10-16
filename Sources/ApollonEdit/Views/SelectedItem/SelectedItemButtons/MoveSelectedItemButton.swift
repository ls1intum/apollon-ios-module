import SwiftUI

struct MoveSelectedItemButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
            .frame(width: 25, height: 25)
            .foregroundColor(.white)
            .padding(5)
            .background {
                Circle()
                    .foregroundColor(.blue)
            }.position(viewModel.moveSelectedItemButtonPosition ?? .zero)
    }
}
