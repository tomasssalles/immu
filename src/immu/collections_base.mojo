comptime ImmuValue = Copyable & ImplicitlyDestructible
comptime ImmuKey = Copyable & ImplicitlyDestructible & Hashable & Equatable


@fieldwise_init
struct EmptyCollectionError(TrivialRegisterPassable, Writable):
    def write_to(self, mut writer: Some[Writer]):
        writer.write("EmptyCollectionError")


trait ImmuCollection(
    ImplicitlyCopyable,
    Defaultable,
    Sized,
    Boolable,
):
    comptime T: ImmuValue

    def __bool__(self) -> Bool:
        return len(self) > 0


trait ImmuSequence(ImmuCollection, Iterable):
    ...