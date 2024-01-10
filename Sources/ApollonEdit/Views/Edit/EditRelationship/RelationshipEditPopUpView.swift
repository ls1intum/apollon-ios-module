import SwiftUI
import ApollonShared

struct RelationshipEditPopUpView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    
    var relationshipName: Binding<String> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.name ?? ""},
            set: { newName in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.name = newName
                }
            }
        )
    }
    
    var relationshipType: Binding<UMLRelationshipType> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.type ?? .classBidirectional},
            set: { newType in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.type = newType
                }
            }
        )
    }
    
    var sourceElement: Binding<String> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.source?.element ?? "" },
            set: { newElement in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.source?.element = newElement
                }
            }
        )
    }

    var targetElement: Binding<String> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.target?.element ?? "" },
            set: { newElement in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.target?.element = newElement
                }
            }
        )
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if(viewModel.diagramType == .classDiagram) {
                ClassDiagramRelationshipEditView(viewModel: viewModel,
                                                 isShowingPopup: $isShowingPopup,
                                                 relationshipType: relationshipType,
                                                 sourceElement: sourceElement,
                                                 targetElement: targetElement)
            } else if (viewModel.diagramType == .objectDiagram) {
                ObjectDiagramRelationshipEditView(viewModel: viewModel,
                                                  isShowingPopup: $isShowingPopup)
            } else if (viewModel.diagramType == .activityDiagram) {
                ActivityDiagramRelationshipEditView(viewModel: viewModel,
                                                   isShowingPopup: $isShowingPopup,
                                                   relationshipName: relationshipName)
            } else if (viewModel.diagramType == .useCaseDiagram) {
                UseCaseDiagramRelationshipEditView(viewModel: viewModel,
                                                   isShowingPopup: $isShowingPopup,
                                                   relationshipName: relationshipName,
                                                   relationshipType: relationshipType)
            } else if (viewModel.diagramType == .communicationDiagram) {
                CommunicationDiagramRelationshipEditView(viewModel: viewModel,
                                                         isShowingPopup: $isShowingPopup,
                                                         sourceElement: sourceElement,
                                                         targetElement: targetElement)
            } else if (viewModel.diagramType == .componentDiagram) {
                ComponentDiagramRelationshipEditView(viewModel: viewModel,
                                                     isShowingPopup: $isShowingPopup,
                                                     relationshipType: relationshipType)
            } else {
                EmptyView()
            }
        }
    }
}
