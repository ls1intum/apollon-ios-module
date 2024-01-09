import SwiftUI
import ApollonShared

struct ComponentDiagramElementEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String

    var body: some View {
        ElementEditTopBar(viewModel: viewModel, isShowingPopup: $isShowingPopup)

        EditDivider()

        ElementNameEditView(viewModel: viewModel, isShowingPopup: $isShowingPopup, elementName: $elementName)
    }
}
