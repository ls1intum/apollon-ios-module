import SwiftUI
import ApollonShared

struct EditSelectedItemButton: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @State private var isShowingPopup: Bool = false

    var body: some View {
        Button {
            isShowingPopup.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(15)
                .background(viewModel.themeColor)
                .clipShape(Circle())
        }
        .frame(width: 50, height: 50)
        .sheet(isPresented: $isShowingPopup, onDismiss: {
            viewModel.adjustDiagramSize()
            viewModel.updateRelationshipPosition()
            isShowingPopup = false
            viewModel.selectedElement = nil
        }) {
            if viewModel.selectedElement is UMLElement {
                ElementEditPopUpView(viewModel: viewModel, isShowingPopup: $isShowingPopup)
                    .presentationDetents([.medium])
            } else if viewModel.selectedElement is UMLRelationship {
                RelationshipEditPopUpView(viewModel: viewModel, isShowingPopup: $isShowingPopup)
                    .presentationDetents([.medium])
            }
        }
    }
}
