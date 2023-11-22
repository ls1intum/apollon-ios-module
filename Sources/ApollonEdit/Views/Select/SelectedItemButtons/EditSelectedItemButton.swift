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
                .frame(width: 35, height: 35)
                .foregroundColor(.white)
                .padding(5)
                .background {
                    Circle()
                        .foregroundColor(.blue)
                }
        }.sheet(isPresented: $isShowingPopup, onDismiss: {
            isShowingPopup = false
            viewModel.selectedElement = nil
            
        }) {
            if viewModel.selectedElement is UMLElement {
                ElementEditPopUpView(viewModel: viewModel, isShowingPopup: $isShowingPopup)
            } else if viewModel.selectedElement is UMLRelationship {
                RelationshipEditPopUpView(viewModel: viewModel, isShowingPopup: $isShowingPopup)
            }
        }
    }
}
