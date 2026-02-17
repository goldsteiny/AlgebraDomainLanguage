public struct ReciprocalUnavailableError: Error, Equatable, Sendable {
    public let context: String?

    public init(_ context: String? = nil) {
        self.context = context
    }
}

public struct DivisionByNonUnitError: Error, Equatable, Sendable {
    public let context: String?

    public init(_ context: String? = nil) {
        self.context = context
    }
}

public struct EmptyCollectionError: Error, Equatable, Sendable {
    public let context: String?

    public init(_ context: String? = nil) {
        self.context = context
    }
}

/// Unified error domain for callers that prefer a single catch site over individual error types.
public enum AlgebraError: Error, Equatable, Sendable {
    case reciprocalUnavailable(ReciprocalUnavailableError)
    case divisionByNonUnit(DivisionByNonUnitError)
    case emptyCollection(EmptyCollectionError)
}

public protocol AlgebraErrorConvertible: Error {
    var asAlgebraError: AlgebraError { get }
}

extension ReciprocalUnavailableError: AlgebraErrorConvertible {
    public var asAlgebraError: AlgebraError { .reciprocalUnavailable(self) }
}

extension DivisionByNonUnitError: AlgebraErrorConvertible {
    public var asAlgebraError: AlgebraError { .divisionByNonUnit(self) }
}

extension EmptyCollectionError: AlgebraErrorConvertible {
    public var asAlgebraError: AlgebraError { .emptyCollection(self) }
}

public extension Result where Failure: AlgebraErrorConvertible {
    @inlinable
    func mapToAlgebraError() -> Result<Success, AlgebraError> {
        mapError(\.asAlgebraError)
    }
}
