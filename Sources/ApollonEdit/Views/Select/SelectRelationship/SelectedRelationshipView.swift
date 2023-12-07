import SwiftUI
import ApollonShared

struct SelectedRelationshipView: View {
    @ObservedObject var viewModel: ApollonEditViewModel

    var body: some View {
        if let relationship = (viewModel.selectedElement as? UMLRelationship) {
            if let pathWithPoints = relationship.pathWithCGPoints {
                pathWithPoints
                    .stroke(Color.blue, lineWidth: 15)
                    .opacity(0.5)
                EditSelectedItemButton(viewModel: viewModel)
                    .position(relationship.badgeLocation ?? .zero)
            }
        }
    }
}

