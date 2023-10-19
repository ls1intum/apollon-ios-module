import SwiftUI
import ApollonShared

struct UseCaseDiagramElementEditView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    
    var body: some View {
        ElementEditTopBar(viewModel: viewModel, isShowingPopup: $isShowingPopup)
        
        Divider()
            .frame(height: 1)
            .overlay(Color.primary)
            .padding([.leading, .trailing], 15)
            .padding([.top, .bottom], 10)
        
        SimpleElementEditView(viewModel: viewModel, isShowingPopup: $isShowingPopup, elementName: $elementName)
    }
}
