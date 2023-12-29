import SwiftUI

struct DeleteSelectedItemButton: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        Button {
            viewModel.removeSelectedItem()
        } label: {
            Image(systemName: "trash")
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
