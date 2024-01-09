import SwiftUI
import ApollonShared

struct ElementEditPopUpView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    
    var elementName: Binding<String> {
        Binding(
            get: { viewModel.selectedElement?.name ?? "" },
            set: { newName in
                viewModel.selectedElement?.name = newName
            }
        )
    }
    
    var elementType: Binding<UMLElementType> {
        Binding(
            get: { (viewModel.selectedElement as? UMLElement)?.type ?? .Class},
            set: { newType in
                if let element = viewModel.selectedElement as? UMLElement {
                    element.type = newType
                }
            }
        )
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if(viewModel.diagramType == .classDiagram) {
                ClassDiagramElementEditView(viewModel: viewModel, 
                                            isShowingPopup: $isShowingPopup,
                                            elementName: elementName,
                                            elementType: elementType)
            } else if (viewModel.diagramType == .objectDiagram) {
                ObjectDiagramElementEditView(viewModel: viewModel,
                                             isShowingPopup: $isShowingPopup,
                                             elementName: elementName)
            } else if (viewModel.diagramType == .useCaseDiagram) {
                UseCaseDiagramElementEditView(viewModel: viewModel,
                                              isShowingPopup: $isShowingPopup,
                                              elementName: elementName)
            } else if (viewModel.diagramType == .communicationDiagram) {
                CommunicationDiagramElementEditView(viewModel: viewModel,
                                                    isShowingPopup: $isShowingPopup,
                                                    elementName: elementName)
            } else if (viewModel.diagramType == .componentDiagram) {
                ComponentDiagramElementEditView(viewModel: viewModel,
                                                    isShowingPopup: $isShowingPopup,
                                                    elementName: elementName)
            } else {
                EmptyView()
            }
        }
    }
}
