import SwiftUI
import ApollonShared

struct ClassDiagramElementEditView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var elementName: String
    @Binding var elementType: UMLElementType
    
    @State var attributeInput: String = ""
    @State var methodInput: String = ""
    @State private var selectedButton: Int = -1
    
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
        ElementEditTopBar(viewModel: viewModel, isShowingPopup: $isShowingPopup)
        
        Divider()
            .frame(height: 1)
            .overlay(Color.primary)
            .padding([.leading, .trailing], 15)
            .padding([.top, .bottom], 10)
        
        if elementType == .package {
            SimpleElementEditView(viewModel: viewModel, isShowingPopup: $isShowingPopup, elementName: $elementName)
        } else {
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
                            viewModel.addAttributeOrMethod(name: attributeInput, type: .classAttribute)
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
                            viewModel.addAttributeOrMethod(name: methodInput, type: .classMethod)
                            methodInput = ""
                        }
                }.padding([.leading, .trailing], 15)
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
