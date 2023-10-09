import SwiftUI
import ApollonShared

struct UMLRendererEdit: View {
    @StateObject public var viewModel: ApollonEditViewModel
    @State var showResetButton = true
    @State var scale: CGFloat = 1
    @State private var startLocation: CGPoint?
    @State private var progressingScale: CGFloat = 1
    @State private var startDragLocation = CGPoint.zero
    @State private var dragStarted = true
    @State private var minScale = 0.1
    @State private var maxScale: CGFloat = 4.0
    
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
        GeometryReader { geometry in
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
                    .scaleEffect(scale * progressingScale)
                    .position(viewModel.currentDragLocation)
                
                resetZoomAndLocationButton
            }.onAppear() {
                scale = scaleToVisible(geometry.size)
                minScale = scaleToVisible(geometry.size)
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
    }
    
    @ViewBuilder
    private var resetZoomAndLocationButton: some View {
        if showResetButton {
            Button {
                viewModel.setDragLocation()
                scale = 1
                progressingScale = 1
            } label: {
                Image(systemName: "scope")
                    .frame(alignment: .topLeading)
                    .foregroundColor(.white)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.blue)
                    }
            }
            .padding(12)
        }
    }
    
    private func scaleToVisible(_ size: CGSize) -> CGFloat {
        guard let diagramSize = viewModel.umlModel?.size else {
            return 1.0
        }
        let scaleWidth = size.width / (diagramSize.width)
        let scaleHeight = size.height / (diagramSize.height)
        let initialScale = min(scaleWidth, scaleHeight)
        
        return min(max(initialScale, minScale), maxScale)
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
        progressingScale = newScale
        
        // Enforce zoom out limit
        if progressingScale * scale < minScale {
            progressingScale = minScale / scale
        }
    }
    
    private func handleMagnificationEnd(_ finalScale: MagnificationGesture.Value) {
        scale *= finalScale
        progressingScale = 1
        
        // Enforce zoom out limit
        if scale < minScale {
            scale = minScale
        }
    }
}
