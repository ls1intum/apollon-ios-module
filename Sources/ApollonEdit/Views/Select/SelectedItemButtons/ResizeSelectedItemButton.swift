import SwiftUI

struct ResizeSelectedItemButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .frame(width: 35, height: 35)
            .foregroundColor(.white)
            .padding(5)
            .background {
                Circle()
                    .foregroundColor(.blue)
            }
    }
}
