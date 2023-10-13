import SwiftUI
import ApollonShared

struct ElementEditPopUpView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @State var attributeInput: String = ""
    @State var methodInput: String = ""
    @State private var selectedButton: Int = -1
    let typesWithChildren: [UMLElementType] = [UMLElementType.Class, UMLElementType.abstractClass, UMLElementType.interface, UMLElementType.enumeration]
    
    var elementName: Binding<String> {
        Binding(
            get: { viewModel.selectedElement?.name ?? "" },
            set: { newName in
                viewModel.selectedElement?.name = newName
            }
        )
    }
    
    var attributeChildren: [UMLElement] {
        guard let children = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else {
            return []
        }
        return children.filter { $0.type == .classAttribute }
    }
    
    var methodChildren: [UMLElement] {
        guard let children = (viewModel.selectedElement as? UMLElement)?.verticallySortedChildren else  {
            return []
        }
        return children.filter { $0.type == .classMethod }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                Text("Edit Element")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer ()
                
                Button("Save") {
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
            }.padding(15)
            
            if typesWithChildren.contains(where: { $0 == (viewModel.selectedElement as? UMLElement)?.type }) {
                VStack {
                    Group {
                        HStack {
                            TextField("Element Name", text: elementName)
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
                                    .foregroundColor(Color.blue)
                            }.frame(width: 30, height: 30)
                        }.padding(.leading, 15)
                            .padding(.trailing, 15)
                        
                        Divider()
                            .frame(height: 1)
                            .overlay(Color.primary)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                    }
                    
                    Group {
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
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        
                        Divider()
                            .frame(height: 1)
                            .overlay(Color.primary)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                    }
                    
                    Group {
                        Text("Attributes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
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
                            }.padding(.leading, 15)
                                .padding(.trailing, 15)
                        }
                        
                        HStack {
                            TextField("", text: $attributeInput)
                                .textFieldStyle(DottedTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .onSubmit {
                                    viewModel.addAttributeOrMethod(name: attributeInput, type: .classAttribute)
                                    attributeInput = ""
                                }
                        }.padding(.leading, 15)
                            .padding(.trailing, 15)
                        
                        Divider()
                            .frame(height: 1)
                            .overlay(Color.primary)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                    }
                    
                    Group {
                        Text("Methods")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
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
                            }.padding(.leading, 15)
                                .padding(.trailing, 15)
                        }
                        
                        HStack {
                            TextField("", text: $methodInput)
                                .textFieldStyle(DottedTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .onSubmit {
                                    viewModel.addAttributeOrMethod(name: methodInput, type: .classMethod)
                                    methodInput = ""
                                }
                        }.padding(.leading, 15)
                            .padding(.trailing, 15)
                    }
                }
            } else {
                VStack {
                    Group {
                        HStack {
                            TextField("Element Name", text: elementName)
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
                                    .foregroundColor(Color.blue)
                            }.frame(width: 30, height: 30)
                        }.padding(.leading, 15)
                            .padding(.trailing, 15)
                    }
                }
            }
        }
    }
    
    func bindingForElement(_ element: UMLElement) -> Binding<String> {
        Binding(
            get: { element.name ?? "" },
            set: { newName in
                if let elementIndex = viewModel.umlModel?.elements?.firstIndex(where: { $0.id == element.id }) {
                    viewModel.umlModel?.elements?[elementIndex].name = newName
                }
            }
        )
    }
}

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

struct PopUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
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
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
    }
}
