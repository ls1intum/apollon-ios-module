import SwiftUI
import ApollonShared

struct SelectedRelationshipView: View {
    @StateObject var viewModel: ApollonEditViewModel
    
    var body: some View {
        if let relationship = (viewModel.selectedElement as? UMLRelationship) {
            if let bounds = relationship.bounds,
               let path = relationship.path,
               let pathWithPoints = relationship.pathWithCGPoints {
                pathWithPoints
                    .stroke(Color.blue, lineWidth: 15)
                    .opacity(0.5)
                EditSelectedItemButton(viewModel: viewModel)
                    .position(calculateMidpoint(of: path, with: bounds))
            }
        }
    }
    
    //TODO: NOT WORKING AS EXPECTED YET
    private func calculateMidpoint(of path: [PathPoint], with pathBounds: Boundary) -> CGPoint {
        if path.count == 3 {
            return CGPoint(x: pathBounds.x + path[1].x, y: pathBounds.y + path[1].y)
        }
        var totalX: CGFloat = 0.0
        var totalY: CGFloat = 0.0
        
        for point in path {
            totalX += pathBounds.x + point.x
            totalY += pathBounds.y + point.y
        }
        
        let midpointX = totalX / CGFloat(path.count)
        let midpointY = totalY / CGFloat(path.count)
        
        return CGPoint(x: midpointX, y: midpointY)
    }
}

