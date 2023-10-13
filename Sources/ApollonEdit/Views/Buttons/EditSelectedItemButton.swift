import SwiftUI
import ApollonShared

struct EditSelectedItemButton: View {
    @StateObject var viewModel: ApollonEditViewModel
    @State private var isShowingPopup: Bool = false
    
    var body: some View {
        Button {
            isShowingPopup.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(viewModel.selectedElement == nil ? .gray : .blue)
                }
        }.disabled(viewModel.selectedElement == nil)
        .sheet(isPresented: $isShowingPopup) {
            if viewModel.selectedElement is UMLElement {
                ElementEditPopUpView(viewModel: viewModel, isShowingPopup: $isShowingPopup)
            } else if viewModel.selectedElement is UMLRelationship {
                RelationshipEditPopUpView(viewModel: viewModel, isShowingPopup: $isShowingPopup)
            }
        }
    }
}
