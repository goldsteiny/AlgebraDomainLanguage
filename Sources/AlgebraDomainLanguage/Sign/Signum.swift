public enum Signum: Int, Sendable, Codable, CaseIterable {
    case negative = -1
    case zero = 0
    case positive = 1
}

public extension Signum {
    @inlinable
    var flipped: Signum {
        switch self {
        case .negative: return .positive
        case .zero: return .zero
        case .positive: return .negative
        }
    }
}

/// An element that carries a sign and can be negated.
public protocol Signed: Sendable {
    var signum: Signum { get }
    var flippedSign: Self { get }
}

public extension Signed {
    @inlinable
    prefix static func - (operand: Self) -> Self {
        operand.flippedSign
    }
}

/// An element decomposable into sign and magnitude.
public protocol AbsoluteValueDecomposable: Signed {
    var absolute: Self { get }
}
