import SwiftUI
import ApollonShared
import ApollonRenderer

struct CommunicationDiagramRelationshipEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var sourceElement: String
    @Binding var targetElement: String

    var messages: [UMLElement] {
        guard let messagesSorted = (viewModel.selectedElement as? UMLRelationship)?.messages else {
            return []
        }
        return messagesSorted.values.filter { $0.type == .communicationLinkMessage }
    }

    var body: some View {
        HStack {
            Text("Communication Link")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            Spacer()

            Button {
                viewModel.removeSelectedItem()
                isShowingPopup = false
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.themeColor)
            }.frame(width: 25, height: 25)

            Button("Done") {
                isShowingPopup = false
                viewModel.selectedElement = nil
                viewModel.adjustDiagramSize()
                viewModel.updateRelationshipPosition()
            }
            .padding(5)
            .foregroundColor(Color(UIColor.systemBackground))
            .background(viewModel.themeColor)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(viewModel.themeColor, lineWidth: 1)
            )
        }.padding([.leading, .top, .trailing], 15)

        EditDivider()

        Text("Messages (\(viewModel.getElementById(elementId: sourceElement)?.name ?? "") ⟶ \(viewModel.getElementById(elementId: targetElement)?.name ?? ""))")
            .font(.title3)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .minimumScaleFactor(0.5)
            .lineLimit(2)
            .padding([.leading, .trailing], 15)

        if let relationship = viewModel.selectedElement as? UMLRelationship {
            EditOrAddLinkMessage(viewModel: viewModel, parentRelationship: relationship, messages: messages)
        }
    }
}

// The View, that allows the user to edit or add a link message of the selected relationship
struct EditOrAddLinkMessage: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @State var parentRelationship: UMLRelationship
    @State var messages: [UMLElement]

    @State var input: String = ""

    // Hacky way to force update the view
    @State private var forceUpdate = false

    var body: some View {
        ForEach($messages, id: \.id) { message in
            HStack {
                TextField("Name", text: bindingForMessage(message.wrappedValue))
                    .textFieldStyle(PopUpTextFieldStyle())

                Button {
                    changeMessageDirection(message: message.wrappedValue)
                } label: {
                    Image(systemName: message.direction.wrappedValue == .source ? "arrow.right" : "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(viewModel.themeColor)
                }
                .frame(width: 25, height: 25)
                .id(forceUpdate)

                Button {
                    removeMessage(message: message.wrappedValue)
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(viewModel.themeColor)
                }.frame(width: 25, height: 25)
            }
            .padding([.leading, .trailing], 15)
        }

        HStack {
            TextField("", text: $input)
                .textFieldStyle(DottedTextFieldStyle())
                .onSubmit {
                    addMessage(name: input)
                    input = ""
                }
        }
        .padding([.leading, .trailing], 15)
    }

    // Creates a binding for the single child element (attribute or method)
    private func bindingForMessage(_ message: UMLElement) -> Binding<String> {
        Binding(
            get: { message.name ?? "" },
            set: { newName in
                if let relationship = viewModel.umlModel.relationships?.first(where: { $0.key == parentRelationship.id }) {
                    if let foundMessage = parentRelationship.messages?.first(where: { $0.key == message.id}) {
                        viewModel.umlModel.relationships?[relationship.key]?.messages?[foundMessage.key]?.name = newName
                    }
                }
            }
        )
    }

    private func changeMessageDirection(message: UMLElement) {
        let newDirection: ElementDirection = message.direction == .source ? .target : .source
        parentRelationship.messages?[message.id ?? ""]?.direction = newDirection
        messages.first(where: { $0.id == message.id })?.direction = newDirection
        self.forceUpdate.toggle()
    }

    // This method adds a new message to the selected relationship
    private func addMessage(name: String) {
        if parentRelationship.messages == nil {
            parentRelationship.messages = [String: UMLElement]()
            let newMessage = UMLElement(name: name, type: .communicationLinkMessage, bounds: Boundary(x: 0, y: 0, width: 20, height: 18.5), direction: .source)
            parentRelationship.messages?[newMessage.id ?? ""] = newMessage
            messages.append(newMessage)
        } else {
            let newMessage = UMLElement(name: name, type: .communicationLinkMessage, bounds: Boundary(x: 0, y: 0, width: 20, height: 18.5), direction: .source)
            parentRelationship.messages?[newMessage.id ?? ""] = newMessage
            messages.append(newMessage)
        }
    }

    // Removes a message from the selected Element
    private func removeMessage(message: UMLElement) {
        parentRelationship.messages?.removeValue(forKey: message.id ?? "")
        messages.removeAll(where: { $0.id == message.id })
    }
}
