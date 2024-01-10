import SwiftUI
import ApollonShared

struct ActivityDiagramElementEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    @Binding var elementType: UMLElementType

    var body: some View {
        ElementEditTopBar(viewModel: viewModel, isShowingPopup: $isShowingPopup)

        EditDivider()

        ElementNameEditView(viewModel: viewModel, isShowingPopup: $isShowingPopup, elementName: $elementName)
    }
}
