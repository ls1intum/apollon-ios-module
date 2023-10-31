import Foundation

public enum Direction: String, Codable {
    case left = "Left"
    case right = "Right"
    case up = "Up"
    case down = "Down"
    case upRight = "Upright"
    case upLeft = "Upleft"
    case downRight = "Downright"
    case downLeft = "Downleft"
    case topRight = "Topright"
    case topLeft = "Topleft"
    case bottomRight = "Bottomright"
    case bottomLeft = "Bottomleft"
    
    public var inverted: Self {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        case .down:
            return .up
        case .up:
            return .down
        case .upRight:
            return .upLeft
        case .upLeft:
            return .upRight
        case .downRight:
            return .downLeft
        case .downLeft:
            return .downRight
        case .topRight:
            return .bottomRight
        case .topLeft:
            return .bottomLeft
        case .bottomRight:
            return .topRight
        case .bottomLeft:
            return .topLeft
        }
    }
}

public enum ElementDirection: String, Codable {
    case source = "source"
    case target = "target"
    
    public var inverted: Self {
        switch self {
        case .source:
            return .target
        case .target:
            return .source
        }
    }
}
