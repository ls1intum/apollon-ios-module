import SwiftUI
import ApollonShared

struct UseCaseDiagramRelationshipEditView: View {
    @StateObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var relationshipName: String
    @Binding var relationshipType: UMLRelationshipType
    @Binding var sourceDirection: Direction
    @Binding var sourceElement: String
    @Binding var targetDirection: Direction
    @Binding var targetElement: String
    
    @State var type: UMLRelationshipType = .useCaseAssociation
    
    var body: some View {
        HStack {
            Text(type.rawValue.replacingOccurrences(of: "UseCase", with: ""))
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            if type != .useCaseAssociation {
                Button {
                    //TO DO
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.blue)
                }.frame(width: 30, height: 30)
            }
            
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
        
        Divider()
            .frame(height: 1)
            .overlay(Color.primary)
            .padding([.leading, .trailing], 15)
            .padding([.top, .bottom], 10)
        
        HStack(alignment: .center) {
            Menu {
                ForEach(UMLDiagramType.useCaseDiagram.diagramRelationshipTypes, id: \.self) { relationship in
                    Button(relationship.rawValue.replacingOccurrences(of: "UseCase", with: "")) {
                        relationshipType = relationship
                        type = relationship
                    }
                }
            } label: {
                Text(type.rawValue.replacingOccurrences(of: "UseCase", with: ""))
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
                        .stroke(.blue, lineWidth: 2)
                )
        }.padding([.leading, .trailing], 15)
            .onAppear {
                type = relationshipType
            }
        
        if type == .useCaseAssociation {
            Divider()
                .frame(height: 1)
                .overlay(Color.primary)
                .padding([.leading, .trailing], 15)
                .padding([.top, .bottom], 10)
            
            TextField("...", text: $relationshipName)
                .textFieldStyle(PopUpTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding([.leading, .trailing], 15)
        }
    }
}
