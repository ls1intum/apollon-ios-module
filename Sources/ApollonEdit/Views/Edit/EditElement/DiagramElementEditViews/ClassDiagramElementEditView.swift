import SwiftUI
import ApollonShared
import ApollonRenderer

struct ClassDiagramElementEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    @Binding var elementType: UMLElementType
    
    @State private var selectedButton: Int = -1
    
    var body: some View {
        ElementEditTopBar(viewModel: viewModel, isShowingPopup: $isShowingPopup)
        
        EditDivider()
        
        ElementNameEditView(viewModel: viewModel, isShowingPopup: $isShowingPopup, elementName: $elementName)
        
        if elementType != .package {
            EditDivider()
            
            HStack(spacing: 0) {
                Button(action: {
                    if selectedButton == 0 {
                        selectedButton = -1
                        (viewModel.selectedElement as? UMLElement)?.type = .Class
                    } else {
                        selectedButton = 0
                        (viewModel.selectedElement as? UMLElement)?.type = .abstractClass
                    }
                }) {
                    Text("Abstract").padding(10)
                }.buttonStyle(RoundedButtonStyle(selected: selectedButton == 0 || (viewModel.selectedElement as? UMLElement)?.type == .abstractClass))
                
                Spacer()
                
                Button(action: {
                    if selectedButton == 1 {
                        selectedButton = -1
                        (viewModel.selectedElement as? UMLElement)?.type = .Class
                    } else {
                        selectedButton = 1
                        (viewModel.selectedElement as? UMLElement)?.type = .interface
                        
                    }
                }) {
                    Text("Interface").padding(10)
                }.buttonStyle(RoundedButtonStyle(selected: selectedButton == 1 || (viewModel.selectedElement as? UMLElement)?.type == .interface))
                
                Spacer()
                
                Button(action: {
                    if selectedButton == 2 {
                        selectedButton = -1
                        (viewModel.selectedElement as? UMLElement)?.type = .Class
                    } else {
                        selectedButton = 2
                        (viewModel.selectedElement as? UMLElement)?.type = .enumeration
                    }
                }) {
                    Text("Enumeration").padding(10)
                }
                .buttonStyle(RoundedButtonStyle(selected: selectedButton == 2 || (viewModel.selectedElement as? UMLElement)?.type == .enumeration))
            }
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing], 15)
            
            EditDivider()
            
            EditOrAddAttributeOrMethodView(viewModel: viewModel,
                                     title: "Atributes",
                                     childTypeToAdd: .classAttribute,
                                     attributeType: .classAttribute,
                                     methodType: .classMethod)
            
            EditDivider()
            
            EditOrAddAttributeOrMethodView(viewModel: viewModel,
                                     title: "Methods",
                                     childTypeToAdd: .classMethod,
                                     attributeType: .classAttribute,
                                     methodType: .classMethod)
        }
    }
}

// The buttonstyle for the different element types button
struct RoundedButtonStyle: ButtonStyle {
    let selected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(selected ? Color(UIColor.systemBackground) : Color.blue)
            .background(selected ? Color.blue : Color.clear)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.blue, lineWidth: 1)
            )
    }
}
