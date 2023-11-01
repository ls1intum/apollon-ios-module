import SwiftUI
import ApollonShared
import ApollonRenderer

// The top bar of the element edit pop up sheet
struct ElementEditTopBar: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    
    var body: some View {
        HStack {
            Text("Edit Element")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer ()
            
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
    }
}

// The textfield, that allows for changing the element name
struct ElementNameEditView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    
    var body: some View {
        HStack {
            TextField("Element Name", text: $elementName)
                .textFieldStyle(PopUpTextFieldStyle())
            Button {
                viewModel.removeSelectedItem()
                isShowingPopup = false
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.blue)
            }.frame(width: 30, height: 30)
        }.padding([.leading, .trailing], 15)
    }
}

// The View, that allows the user to edit or add attributes or methods to the selected element
struct EditOrAddAttributeOrMethodView: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var title: String
    var childTypeToAdd: UMLElementType
    var attributeType: UMLElementType
    var methodType: UMLElementType
    
    @State var input: String = ""
    
    var children: [UMLElement] {
        guard let childrenSorted = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else {
            return []
        }
        return childrenSorted.filter { $0.type == childTypeToAdd }
    }
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .trailing], 15)
        ForEach(children, id: \.id) { child in
            HStack {
                TextField("Name", text: bindingForElement(child))
                    .textFieldStyle(PopUpTextFieldStyle())
                Button {
                    (viewModel.selectedElement as? UMLElement)?.removeChild(child)
                    viewModel.umlModel?.elements?.removeValue(forKey: child.id ?? "")
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
                    addAttributeOrMethod(name: input)
                    input = ""
                }
        }.padding([.leading, .trailing], 15)
    }
    
    // Creates a binding for the single child element (attribute or method)
    private func bindingForElement(_ element: UMLElement) -> Binding<String> {
        Binding(
            get: { element.name ?? "" },
            set: { newName in
                if let element = viewModel.umlModel?.elements?.first(where: { $0.key == element.id }) {
                    viewModel.umlModel?.elements?[element.key]?.name = newName
                }
            }
        )
    }
    
    // This method adds an attribute or method for class and object diagrams to the selected element
    private func addAttributeOrMethod(name: String) {
        guard let elements = viewModel.umlModel?.elements, let children = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else {
            log.warning("Could not find elements in the model")
            return
        }
        var newBounds: Boundary?
        
        if children.isEmpty {
            if let lastBounds = viewModel.selectedElement?.bounds {
                if childTypeToAdd == .classAttribute || childTypeToAdd == .classMethod {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: 40)
                } else if childTypeToAdd == .objectAttribute || childTypeToAdd == .objectMethod {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: 30)
                }
            }
        }
        
        let containsAttributes: Bool = children.contains(where: { $0.type == attributeType })
        let containsMethods: Bool = children.contains(where: { $0.type == methodType })
        
        if childTypeToAdd == attributeType && !children.isEmpty {
            if !containsAttributes && containsMethods {
                if let lastBounds = children.first(where: { $0.type == methodType })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y, width: lastBounds.width, height: lastBounds.height)
                }
            } else {
                if let lastBounds = children.last(where: { $0.type == attributeType })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            }
        }
        
        if childTypeToAdd == methodType && !children.isEmpty {
            if !containsMethods && containsAttributes {
                if let lastBounds = children.last(where: { $0.type == attributeType })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            } else {
                if let lastBounds = children.last(where: { $0.type == methodType })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            }
        }
        
        let newChild = UMLElement(name: name, type: childTypeToAdd, owner: viewModel.selectedElement?.id, bounds: newBounds)
        let newItemHeight = (viewModel.selectedElement?.bounds?.height ?? 0) + (newChild.bounds?.height ?? 0)
        viewModel.selectedElement?.bounds?.height = newItemHeight
        (viewModel.selectedElement as? UMLElement)?.addChild(newChild)
        viewModel.umlModel?.elements?[newChild.id ?? ""] = newChild
        
        if childTypeToAdd == attributeType && containsMethods {
            if let firstMethodIndex = children.firstIndex(where: { $0.type == methodType }) {
                for (index, child) in children.enumerated() where index >= firstMethodIndex {
                    for childElement in elements where child.id == childElement.key {
                        let newYForElement = (viewModel.umlModel?.elements?[childElement.key]?.bounds?.y ?? 0) + (newBounds?.height ?? 0)
                        viewModel.umlModel?.elements?[childElement.key]?.bounds?.y = newYForElement
                    }
                }
            }
        }
    }
}

// The custom Divider to use between sections of the edit pop up sheet
struct EditDivider: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .overlay(Color.primary)
            .padding([.leading, .trailing], 15)
            .padding([.top, .bottom], 10)
    }
}

struct PopUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primary, lineWidth: 1)
            )
    }
}

struct DottedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
    }
}
