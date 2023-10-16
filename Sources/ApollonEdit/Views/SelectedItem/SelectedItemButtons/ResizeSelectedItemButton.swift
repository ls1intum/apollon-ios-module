import SwiftUI

struct ResizeSelectedItemButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        Button {
            
        } label: {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    Circle()
                        .foregroundColor(.blue)
                }
        }.position(viewModel.resizeSelectedItemButtonPosition)
    }
}
