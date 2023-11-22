import SwiftUI

struct AddElementButton: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isAddElementMenuVisible: Bool
    
    var body: some View {
        Button {
            isAddElementMenuVisible = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(Color.blue)
                .symbolRenderingMode(.hierarchical)
        }.frame(maxWidth: .infinity, alignment: .center)
    }
}
