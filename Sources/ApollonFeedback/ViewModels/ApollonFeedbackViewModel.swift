import Foundation
import SwiftUI
import ApollonRenderer
import ApollonShared
import SharedModels

@MainActor
open class ApollonFeedbackViewModel: ApollonViewModel {
    @Published public var result: Result
    @Published var selectedElement: SelectableUMLItem?
    @Published var highlights: [UMLHighlight] = []
    @Published var selectedFeedbackId: Int?
    @Published var showFeedback = false
    private var symbolSize = 30.0

    public init(umlModel: UMLModel, diagramType: ApollonShared.UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool, result: Result) {
        self.result = result
        super.init(umlModel: umlModel, diagramType: diagramType, fontSize: fontSize, diagramOffset: diagramOffset, isGridBackground: isGridBackground)
    }

    func setupHighlights(basedOn feedbacks: [Feedback]) {
        guard umlModel.elements != nil else {
            log.error("Could not find elements in the model when attempting to setup highlights")
            return
        }

        for feedback in feedbacks {
            guard let referencedItemId = feedback.reference?.components(separatedBy: ":")[1],
                  let referencedItem = findSelectableItem(byId: referencedItemId),
                  let elementRect = referencedItem.boundsAsCGRect,
                  let badgeLocation = referencedItem.badgeLocation else {
                log.error("Could not create a highlight for the following referenced feedback: \(feedback)")
                continue
            }
            let highlightPath = Path(elementRect)

            let newHighlight = UMLHighlight(assessmentFeedbackId: feedback.id ?? 0,
                                            symbol: UMLBadgeSymbol.symbol(forCredits: feedback.credits ?? 0.0),
                                            elementBounds: elementRect,
                                            path: highlightPath,
                                            badgeLocation: badgeLocation)
            highlights.append(newHighlight)
        }
    }

    func renderHighlights(_ context: inout GraphicsContext, size: CGSize) {
        let context = UMLGraphicsContext(context, offset: diagramOffset)

        // Highlight selected element if there is one
        if let selectedElement,
           let highlightPath = selectedElement.highlightPath {
            if type(of: selectedElement) == UMLRelationship.self {
                context.fill(highlightPath,
                             with: .color(Color.blue.opacity(0.5)))
            } else {
                context.stroke(highlightPath,
                               with: .color(Color.blue.opacity(0.5)),
                               style: .init(lineWidth: 5)
                )
            }
        }

        // Highlight all elements associated with a feedback
        for highlight in highlights {
            let badgeSymbol = highlight.symbol
            let badgeCircleSideLength = symbolSize

            let badgeCircleX: CGFloat
            let badgeCircleY: CGFloat

            // Determine badge coordinates
            badgeCircleX = highlight.badgeLocation.x - badgeCircleSideLength / 2
            badgeCircleY = highlight.badgeLocation.y - badgeCircleSideLength / 2

            guard let resolvedBadgeSymbol = context.resolveSymbol(id: badgeSymbol) else {
                log.warning("Could not resolve the highlight badge for: \(highlight)")
                continue
            }

            let badgeRect = CGRect(x: badgeCircleX,
                                   y: badgeCircleY,
                                   width: badgeCircleSideLength,
                                   height: badgeCircleSideLength)

            let badgeCircle = Path(ellipseIn: badgeRect)

            context.fill(badgeCircle, with: .color(Color(UIColor.systemGray5).opacity(0.85)))
            context.draw(resolvedBadgeSymbol, in: badgeRect.insetBy(dx: 6, dy: 6))
        }
    }

    func selectItem(at point: CGPoint) {
        self.selectedElement = getSelectableItem(at: point)

        if let selectedElement {
            if let matchingHighlight = highlights.first(where: { $0.elementBounds == selectedElement.boundsAsCGRect }) {
                self.selectedFeedbackId = matchingHighlight.assessmentFeedbackId
                self.showFeedback = true
            } else {
                self.selectedFeedbackId = nil
                self.showFeedback = false
            }
        }
    }

    private func getSelectableItem(at point: CGPoint) -> SelectableUMLItem? {
        let point = CGPoint(x: point.x - diagramOffset.x,
                            y: point.y - diagramOffset.y)

        /// Check for UMLRelationship
        if let relationship = umlModel.relationships?.first(where: { $0.value.boundsContains(point: point) }) {
            return relationship.value
        }
        /// Check for UMLElement
        if let element = umlModel.elements?.first(where: { $0.value.boundsContains(point: point) }) {
            if let children = element.value.children {
                for child in children {
                    if child.boundsContains(point: point) {
                        return child
                    }
                }
                return element.value
            } else {
                return element.value
            }
        }

        /// Return nil if nothing found
        return nil
    }

    private func findSelectableItem(byId id: String) -> SelectableUMLItem? {
        var selectableItem: SelectableUMLItem?

        if let elements = umlModel.elements,
           let foundElement = elements.values.first(where: { $0.id == id }) {
            selectableItem = foundElement
        } else if let relationships = umlModel.relationships,
                  let foundRelationship = relationships.values.first(where: { $0.id == id }) {
            selectableItem = foundRelationship
        }

        return selectableItem
    }

    func getFeedback(byId id: Int) -> Feedback? {
        result.feedbacks?.first(where: { $0.id == id })
    }

    @ViewBuilder
    /// Generates all possible symbol views that can be drawn on the canvas used for rendering highlights
    func generatePossibleSymbols() -> some View {
        // Positive referenced feedback
        Image(UMLBadgeSymbol.checkmark.imageName, bundle: .module)
            .tag(UMLBadgeSymbol.checkmark)

        // Negative referenced feedback
        Image(UMLBadgeSymbol.cross.imageName, bundle: .module)
            .tag(UMLBadgeSymbol.cross)

        // Neutral referenced feedback
        Image(UMLBadgeSymbol.exclamation.imageName, bundle: .module)
            .tag(UMLBadgeSymbol.exclamation)
    }
}

struct UMLHighlight {
    var assessmentFeedbackId: Int
    var symbol: UMLBadgeSymbol
    var elementBounds: CGRect
    var path: Path
    var badgeLocation: CGPoint
}

enum UMLBadgeSymbol {
    case checkmark
    case cross
    case exclamation

    var imageName: String {
        switch self {
        case .checkmark:
            return "checkmark-badge"
        case .cross:
            return "xmark-badge"
        case .exclamation:
            return "exclamation-badge"
        }
    }

    static func symbol(forCredits credits: Double) -> Self {
        if credits < 0.0 {
            return Self.cross
        } else if credits > 0.0 {
            return Self.checkmark
        } else {
            return Self.exclamation
        }
    }
}
