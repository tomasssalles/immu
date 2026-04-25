comptime ImmuValue = Copyable
comptime ImmuKey = Copyable & Hashable & Equatable


trait ImmuCollection(
    Defaultable,
    Sized,
    Boolable, 
    Movable,
    Copyable,
):
    comptime _VT: ImmuValue

    def __bool__(self) -> Bool:
        return len(self) > 0


trait ImmuSequence(ImmuCollection, Iterable):
    ...


@fieldwise_init
struct EmptyCollectionError(Writable):
    ...