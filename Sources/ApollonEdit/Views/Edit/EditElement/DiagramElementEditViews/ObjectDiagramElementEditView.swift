import SwiftUI
import ApollonShared
import ApollonRenderer

struct ObjectDiagramElementEditView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    @Binding var elementType: UMLElementType
    
    @State var attributeInput: String = ""
    @State var methodInput: String = ""
    
    var attributeChildren: [UMLElement] {
        guard let children = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else {
            return []
        }
        return children.filter { $0.type == .objectAttribute }
    }
    
    var methodChildren: [UMLElement] {
        guard let children = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else  {
            return []
        }
        return children.filter { $0.type == .objectMethod }
    }
    
    var body: some View {
        ElementEditTopBar(viewModel: viewModel, isShowingPopup: $isShowingPopup)
        
        Divider()
            .frame(height: 1)
            .overlay(Color.primary)
            .padding([.leading, .trailing], 15)
            .padding([.top, .bottom], 10)
        
        HStack {
            TextField("Element Name", text: $elementName)
                .textFieldStyle(PopUpTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            Button {
                viewModel.removeSelectedItem()
                isShowingPopup = false
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.blue)
            }.frame(width: 30, height: 30)
        }.padding([.leading, .trailing], 15)
        
        Divider()
            .frame(height: 1)
            .overlay(Color.primary)
            .padding([.leading, .trailing], 15)
            .padding([.top, .bottom], 10)
        
        Group {
            Text("Attributes")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], 15)
            ForEach(attributeChildren, id: \.id) { attribute in
                HStack {
                    TextField("Enter Attribute Name", text: bindingForElement(attribute))
                        .textFieldStyle(PopUpTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Button {
                        (viewModel.selectedElement as? UMLElement)?.removeChild(attribute)
                        viewModel.umlModel?.elements?.removeAll { $0.id ?? "" == attribute.id ?? ""}
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.blue)
                    }.frame(width: 30, height: 30)
                }.padding([.leading, .trailing], 15)
            }
            
            HStack {
                TextField("", text: $attributeInput)
                    .textFieldStyle(DottedTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onSubmit {
                        addAttributeOrMethod(name: attributeInput, type: .objectAttribute)
                        attributeInput = ""
                    }
            }.padding([.leading, .trailing], 15)
        }
        
        Divider()
            .frame(height: 1)
            .overlay(Color.primary)
            .padding([.leading, .trailing], 15)
            .padding([.top, .bottom], 10)
        
        Group {
            Text("Methods")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], 15)
            ForEach(methodChildren, id: \.id) { method in
                HStack {
                    TextField("Enter Method Name", text: bindingForElement(method))
                        .textFieldStyle(PopUpTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Button {
                        (viewModel.selectedElement as? UMLElement)?.removeChild(method)
                        viewModel.umlModel?.elements?.removeAll { $0.id ?? "" == method.id ?? ""}
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.blue)
                    }.frame(width: 30, height: 30)
                }.padding([.leading, .trailing], 15)
            }
            
            HStack {
                TextField("", text: $methodInput)
                    .textFieldStyle(DottedTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onSubmit {
                        addAttributeOrMethod(name: methodInput, type: .objectMethod)
                        methodInput = ""
                    }
            }.padding([.leading, .trailing], 15)
        }
    }
    
    private func bindingForElement(_ element: UMLElement) -> Binding<String> {
        Binding(
            get: { element.name ?? "" },
            set: { newName in
                if let elementIndex = viewModel.umlModel?.elements?.firstIndex(where: { $0.id == element.id }) {
                    viewModel.umlModel?.elements?[elementIndex].name = newName
                }
            }
        )
    }
    
    private func addAttributeOrMethod(name: String, type: UMLElementType) {
        guard let elements = viewModel.umlModel?.elements, let children = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else {
            log.warning("Could not find elements in the model")
            return
        }
        var newBounds: Boundary?
        
        if children.isEmpty {
            if let lastBounds = viewModel.selectedElement?.bounds {
                newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: 30)
            }
        }
        
        let containsAttributes: Bool = children.contains(where: { $0.type == .objectAttribute })
        let containsMethods: Bool = children.contains(where: { $0.type == .objectMethod })
        
        if type == .objectAttribute && !children.isEmpty {
            if !containsAttributes && containsMethods {
                if let lastBounds = children.first(where: { $0.type == .objectMethod })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y, width: lastBounds.width, height: lastBounds.height)
                }
            } else {
                if let lastBounds = children.last(where: { $0.type == .objectAttribute })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            }
        }
        
        if type == .objectMethod && !children.isEmpty {
            if !containsMethods && containsAttributes {
                if let lastBounds = children.last(where: { $0.type == .objectAttribute })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            } else {
                if let lastBounds = children.last(where: { $0.type == .objectMethod })?.bounds {
                    newBounds = Boundary(x: lastBounds.x, y: lastBounds.y + lastBounds.height, width: lastBounds.width, height: lastBounds.height)
                }
            }
        }
        
        let newChild = UMLElement(name: name, type: type, owner: viewModel.selectedElement?.id, bounds: newBounds)
        let newItemHeight = (viewModel.selectedElement?.bounds?.height ?? 0) + (newChild.bounds?.height ?? 0)
        viewModel.selectedElement?.bounds?.height = newItemHeight
        (viewModel.selectedElement as? UMLElement)?.addChild(newChild)
        viewModel.umlModel?.elements?.append(newChild)
        
        if type == .objectAttribute && containsMethods {
            if let firstMethodIndex = children.firstIndex(where: { $0.type == .objectMethod }) {
                for (index, child) in children.enumerated() where index >= firstMethodIndex {
                    for (indexElement, childElement) in elements.enumerated() where child.id == childElement.id {
                        let newYForElement = (viewModel.umlModel?.elements?[indexElement].bounds?.y ?? 0) + (newBounds?.height ?? 0)
                        viewModel.umlModel?.elements?[indexElement].bounds?.y = newYForElement
                    }
                }
            }
        }
    }
}
