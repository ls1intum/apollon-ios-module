import Foundation

/// The Boundary of elements and relationships
public struct Boundary: Codable {
    // swiftlint:disable identifier_name
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    // swiftlint:enable identifier_name
}

/// Hashable (Equatable) extension
extension Boundary: Hashable {
    public static func == (lhs: Boundary, rhs: Boundary) -> Bool {
        return lhs.x == rhs.x &&
        lhs.y == rhs.y &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(width)
        hasher.combine(height)
    }
}
