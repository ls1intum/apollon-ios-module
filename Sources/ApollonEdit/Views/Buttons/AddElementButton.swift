import SwiftUI

struct AddElementButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isAddElementMenuVisible: Bool
    
    var body: some View {
        Button {
            isAddElementMenuVisible.toggle()
        } label: {
            Image(systemName: "square.badge.plus")
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.blue)
                }
        }
    }
}
