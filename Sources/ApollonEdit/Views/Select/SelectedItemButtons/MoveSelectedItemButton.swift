import SwiftUI

struct MoveSelectedItemButton: View { 
    @ObservedObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        Group {
            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(15)
                .background(viewModel.themeColor)
                .clipShape(Circle())
        }
        .frame(width: 50, height: 50)
    }
}
