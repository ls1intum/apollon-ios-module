import SwiftUI
import ApollonShared

struct ComponentDiagramRelationshipEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
    @Binding var isShowingPopup: Bool
    @Binding var relationshipType: UMLRelationshipType

    @State var type: UMLRelationshipType = .componentDependency

    var body: some View {
        HStack {
            Text("Association")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button {
                if let relationship = (viewModel.selectedElement as? UMLRelationship) {
                    relationship.switchSourceAndTarget()
                    viewModel.updateRelationshipPosition()
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.themeColor)
            }.frame(width: 25, height: 25)

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

        // RelationshipType picker
        HStack {
            Menu {
                ForEach(UMLDiagramType.componentDiagram.diagramRelationshipTypes, id: \.self) { relationship in
                    Button(relationship.rawValue.replacingOccurrences(of: "Component", with: "")) {
                        relationshipType = relationship
                        type = relationship
                    }
                }
            } label: {
                Text(type.rawValue.replacingOccurrences(of: "Component", with: ""))
                    .font(.headline)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .tint(viewModel.themeColor)
                    .frame(width: 15, height: 15)
            }.frame(maxWidth: .infinity)
                .tint(viewModel.themeColor)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.themeColor, lineWidth: 1)
                )
        }.padding([.leading, .trailing], 15)
            .onAppear {
                type = relationshipType
            }
    }
}
