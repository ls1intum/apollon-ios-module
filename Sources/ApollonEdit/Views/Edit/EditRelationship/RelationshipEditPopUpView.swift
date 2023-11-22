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
    
    var sourceDirection: Binding<Direction> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.source?.direction ?? .down },
            set: { newDirection in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.source?.direction = newDirection
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
    
    var targetDirection: Binding<Direction> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.target?.direction ?? .down },
            set: { newDirection in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.target?.direction = newDirection
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
                                                 sourceDirection: sourceDirection,
                                                 sourceElement: sourceElement,
                                                 targetDirection: targetDirection,
                                                 targetElement: targetElement)
            } else if (viewModel.diagramType == .objectDiagram) {
                ObjectDiagramRelationshipEditView(viewModel: viewModel,
                                                  isShowingPopup: $isShowingPopup)
            } else if (viewModel.diagramType == .useCaseDiagram) {
                UseCaseDiagramRelationshipEditView(viewModel: viewModel,
                                                   isShowingPopup: $isShowingPopup,
                                                   relationshipName: relationshipName,
                                                   relationshipType: relationshipType,
                                                   sourceDirection: sourceDirection,
                                                   sourceElement: sourceElement,
                                                   targetDirection: targetDirection,
                                                   targetElement: targetElement)
            } else if (viewModel.diagramType == .communicationDiagram) {
                CommunicationDiagramRelationshipEditView(viewModel: viewModel,
                                                         isShowingPopup: $isShowingPopup,
                                                         sourceElement: sourceElement,
                                                         targetElement: targetElement)
            } else {
                EmptyView()
            }
        }
    }
}
