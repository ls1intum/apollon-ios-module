import SwiftUI
import ApollonShared

struct UMLRendererEdit: View {
    @StateObject public var viewModel: ApollonEditViewModel
    @State private var startLocation: CGPoint?
    @State private var startDragLocation = CGPoint.zero
    @State private var dragStarted = true
    
    var elementDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if var newLocation = startLocation {
                    newLocation.x += value.translation.width
                    newLocation.y += value.translation.height
                    viewModel.updateElementPosition(location: newLocation, drag: value)
                }
            }.onEnded { value in
                startLocation?.x += value.translation.width
                startLocation?.y += value.translation.height
            }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                if viewModel.isGridBackground {
                    GridBackgroundView()
                }
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.render(&context, size: size)
                }
                Canvas(rendersAsynchronously: true) { context, size in
                    viewModel.renderHighlights(&context, size: size)
                }.onTapGesture { tapLocation in
                    viewModel.selectItem(at: tapLocation)
                    if let bounds = viewModel.selectedElement?.bounds {
                        startLocation = CGPoint(x: bounds.x, y: bounds.y)
                    }
                }.highPriorityGesture(viewModel.selectedElement != nil ? elementDrag : nil)
            }.frame(minWidth: viewModel.diagramSize.width, minHeight: viewModel.diagramSize.height)
                .padding()
                .scaleEffect(viewModel.scale * viewModel.progressingScale)
                .position(viewModel.currentDragLocation)
        }.onChange(of: viewModel.diagramSize) { _ in
            viewModel.setDragLocation()
        }.gesture(
            viewModel.selectedElement == nil ?
            DragGesture()
                .onChanged(handleDrag)
                .onEnded { _ in
                    dragStarted = true
                }
            : nil
        ).simultaneousGesture(
            viewModel.selectedElement == nil ?
            MagnificationGesture()
                .onChanged(handleMagnification)
                .onEnded(handleMagnificationEnd)
            : nil
        )
    }
    
    private func handleDrag(_ gesture: DragGesture.Value) {
        if dragStarted {
            dragStarted = false
            startDragLocation = viewModel.currentDragLocation
        }
        viewModel.setDragLocation(at: CGPoint(x: startDragLocation.x + gesture.translation.width,
                                              y: startDragLocation.y + gesture.translation.height))
    }
    
    private func handleMagnification(_ newScale: MagnificationGesture.Value) {
        viewModel.progressingScale = newScale
        
        // Enforce zoom out limit
        if viewModel.progressingScale * viewModel.scale < viewModel.minScale {
            viewModel.progressingScale = viewModel.minScale / viewModel.scale
        }
    }
    
    private func handleMagnificationEnd(_ finalScale: MagnificationGesture.Value) {
        viewModel.scale *= finalScale
        viewModel.progressingScale = 1
        
        // Enforce zoom out limit
        if viewModel.scale < viewModel.minScale {
            viewModel.scale = viewModel.minScale
        }
    }
}
