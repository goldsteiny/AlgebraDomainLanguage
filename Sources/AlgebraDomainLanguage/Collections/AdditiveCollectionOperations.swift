public extension Array where Element: AdditiveMonoid {
    @inlinable
    var sum: Element {
        guard let values = NonEmpty(self) else { return .zero }
        return Element.sum(values)
    }
}

public extension Array where Element: AdditiveSemigroup {
    @inlinable
    var sumResult: Result<Element, EmptyCollectionError> {
        guard let values = NonEmpty(self) else { return .failure(EmptyCollectionError()) }
        return .success(Element.sum(values))
    }
}

public extension NonEmpty where Element: AdditiveSemigroup {
    @inlinable
    var sum: Element {
        Element.sum(self)
    }
}
