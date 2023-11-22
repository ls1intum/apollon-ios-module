import SwiftUI
import ApollonShared

struct ClassDiagramRelationshipEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var relationshipType: UMLRelationshipType
    @Binding var sourceDirection: Direction
    @Binding var sourceElement: String
    @Binding var targetDirection: Direction
    @Binding var targetElement: String
    
    @State var type: UMLRelationshipType = .classBidirectional
    
    var sourceMultiplicity: Binding<String> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.source?.multiplicity ?? "" },
            set: { newMultiplicity in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.source?.multiplicity = newMultiplicity
                }
            }
        )
    }
    
    var sourceRole: Binding<String> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.source?.role ?? "" },
            set: { newRole in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.source?.role = newRole
                }
            }
        )
    }
    
    var targetMultiplicity: Binding<String> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.target?.multiplicity ?? "" },
            set: { newMultiplicity in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.target?.multiplicity = newMultiplicity
                }
            }
        )
    }
    
    var targetRole: Binding<String> {
        Binding(
            get: { (viewModel.selectedElement as? UMLRelationship)?.target?.role ?? "" },
            set: { newRole in
                if let relationship = viewModel.selectedElement as? UMLRelationship {
                    relationship.target?.role = newRole
                }
            }
        )
    }
    
    var body: some View {
        HStack {
            Text("Association")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button {
                //TO DO
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.blue)
            }.frame(width: 30, height: 30)
            
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
        
        // RelationshipType picker
        HStack {
            Menu {
                ForEach(UMLDiagramType.classDiagram.diagramRelationshipTypes, id: \.self) { relationship in
                    Button(relationship.rawValue.replacingOccurrences(of: "Class", with: "")) {
                        relationshipType = relationship
                        type = relationship
                    }
                }
            } label: {
                Text(type.rawValue.replacingOccurrences(of: "Class", with: ""))
                    .font(.title2)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .tint(.blue)
                    .frame(width: 15, height: 15)
            }.frame(maxWidth: .infinity)
                .tint(.blue)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.blue, lineWidth: 1)
                )
        }.padding([.leading, .trailing], 15)
            .onAppear {
                type = relationshipType
            }
        
        EditDivider()
        
        // Source Multiplicity and Role Edit
        MultiplicityOrRoleEditView(elementName: viewModel.getElementTypeById(elementId: sourceElement)?.rawValue ?? "",
                                   multiplicityText: sourceMultiplicity,
                                   roleText: sourceRole)
        
        EditDivider()
        
        // Target Multiplicity and Role edit
        MultiplicityOrRoleEditView(elementName: viewModel.getElementTypeById(elementId: targetElement)?.rawValue ?? "",
                                   multiplicityText: targetMultiplicity,
                                   roleText: targetRole)
    }
}

struct MultiplicityOrRoleEditView: View {
    @State var elementName: String
    @Binding var multiplicityText: String
    @Binding var roleText: String
    
    var body: some View {
        Text(elementName)
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .trailing], 15)
        
        HStack {
            Text("Multiplicity")
                .font(.title2)
            TextField("", text: $multiplicityText)
                .textFieldStyle(PopUpTextFieldStyle())
        }.padding([.leading, .trailing], 15)
        
        HStack {
            Text("Role")
                .font(.title2)
            TextField("", text: $roleText)
                .textFieldStyle(PopUpTextFieldStyle())
        }.padding([.leading, .trailing], 15)
    }
}
