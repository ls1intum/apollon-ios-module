import SwiftUI
import ApollonShared

struct UseCaseDiagramRelationshipEditView: View {
    @ObservedObject var viewModel: ApollonEditViewModel
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
                    if let relationship = (viewModel.selectedElement as? UMLRelationship) {
                        relationship.switchSourceAndTarget()
                        viewModel.updateRelationshipPosition()
                    }
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(viewModel.themeColor)
                }
                .frame(width: 30, height: 30)
                .onAppear() {
                    relationshipName = ""
                }
            }

            Button {
                viewModel.removeSelectedItem()
                isShowingPopup = false
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(viewModel.themeColor)
            }.frame(width: 30, height: 30)

            Button("Done") {
                isShowingPopup = false
                viewModel.selectedElement = nil
                viewModel.adjustDiagramSize()
                viewModel.updateRelationshipPosition()
            }.padding(10)
                .foregroundColor(Color(UIColor.systemBackground))
                .background(viewModel.themeColor)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.themeColor, lineWidth: 1)
                )
        }.padding([.leading, .top, .trailing], 15)

        EditDivider()

        HStack {
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
                    .tint(viewModel.themeColor)
                    .frame(width: 15, height: 15)
            }.frame(maxWidth: .infinity)
                .tint(viewModel.themeColor)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.themeColor, lineWidth: 1)
                )
        }.padding([.leading, .trailing], 15)
            .onAppear {
                type = relationshipType
            }

        if type == .useCaseAssociation {
            EditDivider()

            TextField("...", text: $relationshipName)
                .textFieldStyle(PopUpTextFieldStyle())
                .padding([.leading, .trailing], 15)
        }
    }
}
