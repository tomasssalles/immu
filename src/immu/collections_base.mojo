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


# TODO: For Writable sequences, take a look at https://github.com/modular/modular/blob/95429ae83a78d120783802c19ee856653c64b621/mojo/stdlib/std/format/_utils.mojo#L84