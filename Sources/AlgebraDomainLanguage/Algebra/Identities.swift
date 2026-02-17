/// Additive identity element (0).
public protocol Zero: Sendable {
    static var zero: Self { get }
    var isZero: Bool { get }
}

public extension Zero where Self: Equatable {
    @inlinable
    var isZero: Bool { self == .zero }
}

/// Multiplicative identity element (1).
public protocol One: Sendable {
    static var one: Self { get }
    var isOne: Bool { get }
}

public extension One where Self: Equatable {
    @inlinable
    var isOne: Bool { self == .one }
}
