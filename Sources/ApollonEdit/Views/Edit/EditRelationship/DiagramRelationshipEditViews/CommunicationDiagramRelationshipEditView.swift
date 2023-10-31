import SwiftUI
import ApollonShared
import ApollonRenderer

struct CommunicationDiagramRelationshipEditView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var sourceElement: String
    @Binding var targetElement: String
    
    var body: some View {
        HStack {
            Text("Communication Link")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                viewModel.removeSelectedItem()
                isShowingPopup = false
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.blue)
            }.frame(width: 30, height: 30)
            
            Button("Done") {
                isShowingPopup = false
                viewModel.selectedElement = nil
            }.padding(10)
                .foregroundColor(Color(UIColor.systemBackground))
                .background(Color.blue)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }.padding([.leading, .top, .trailing], 15)
        
        EditDivider()
        
        Text("Messages (\(viewModel.getElementById(elementId: sourceElement)?.name ?? "") ⟶ \(viewModel.getElementById(elementId: targetElement)?.name ?? ""))")
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .padding([.leading, .trailing], 15)
        
        if let relationship = viewModel.selectedElement as? UMLRelationship {
            EditOrAddLinkMessage(viewModel: viewModel, parentRelationship: relationship, messages: relationship.messages ?? [])
        }
    }
}

// The View, that allows the user to edit or add a link message of the selected relationship
// TODO: FINISH THE FUNCTION (NOT FULLY FUNCTIONAL YET)
struct EditOrAddLinkMessage: View {
    @StateObject var viewModel: ApollonEditViewModel
    @State var parentRelationship: UMLRelationship
    @State var messages: [UMLElement]
    
    @State var input: String = ""
    
    var body: some View {
        ForEach(messages, id: \.id) { message in
            HStack {
                TextField("Name", text: bindingForMessage(message))
                    .textFieldStyle(PopUpTextFieldStyle())
                
                Button {
                    changeMessageDirection(message: message)
                } label: {
                    Image(systemName: message.direction == .source ? "arrow.right" : "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.blue)
                }.frame(width: 30, height: 30)
                
                Button {
                    parentRelationship.messages?.removeAll { $0.id == message.id }
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.blue)
                }.frame(width: 30, height: 30)
            }.padding([.leading, .trailing], 15)
        }
        
        HStack {
            TextField("", text: $input)
                .textFieldStyle(DottedTextFieldStyle())
                .onSubmit {
                    addMessage(name: input)
                    input = ""
                }
        }.padding([.leading, .trailing], 15)
    }
    
    // Creates a binding for the single child element (attribute or method)
    private func bindingForMessage(_ message: UMLElement) -> Binding<String> {
        Binding(
            get: { message.name ?? "" },
            set: { newName in
                if let relationshipIndex = viewModel.umlModel?.relationships?.firstIndex(where: { $0.id == parentRelationship.id }) {
                    if let messageIndex = parentRelationship.messages?.firstIndex(where: { $0.id == message.id}) {
                        viewModel.umlModel?.relationships?[relationshipIndex].messages?[messageIndex].name = newName
                    }
                }
            }
        )
    }
    private func changeMessageDirection(message: UMLElement) {
        message.direction = message.direction?.inverted
    }
    
    // This method adds an attribute or method for class and object diagrams to the selected element
    // TODO: FINISH THE FUNCTION
    private func addMessage(name: String) {
//        guard let elements = viewModel.umlModel?.elements, let children = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else {
//            log.warning("Could not find elements in the model")
//            return
//        }
//        var newBounds: Boundary?
    }
}