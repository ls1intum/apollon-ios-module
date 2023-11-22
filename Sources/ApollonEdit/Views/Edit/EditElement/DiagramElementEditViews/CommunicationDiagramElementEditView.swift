import SwiftUI
import ApollonShared
import ApollonRenderer

struct CommunicationDiagramElementEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    
    var body: some View {
        ElementEditTopBar(viewModel: viewModel, isShowingPopup: $isShowingPopup)
        
        EditDivider()
        
        ElementNameEditView(viewModel: viewModel, isShowingPopup: $isShowingPopup, elementName: $elementName)
        
        EditDivider()
        
        EditOrAddAttributeOrMethodView(viewModel: viewModel,
                                 title: "Attributes",
                                 childTypeToAdd: .objectAttribute,
                                 attributeType: .objectAttribute,
                                 methodType: .objectMethod)
        
        EditDivider()
        
        EditOrAddAttributeOrMethodView(viewModel: viewModel,
                                 title: "Methods",
                                 childTypeToAdd: .objectMethod,
                                 attributeType: .objectAttribute,
                                 methodType: .objectMethod)
    }
}
