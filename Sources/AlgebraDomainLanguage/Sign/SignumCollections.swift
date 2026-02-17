public extension Array where Element == Signum {
    /// Empty array returns `.positive` (multiplicative identity for sign).
    @inlinable
    func product() -> Signum {
        reduce(.positive) { partial, next in
            switch (partial, next) {
            case (.zero, _), (_, .zero):
                return .zero
            case (.positive, .positive), (.negative, .negative):
                return .positive
            case (.positive, .negative), (.negative, .positive):
                return .negative
            }
        }
    }
}
