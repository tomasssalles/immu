comptime CollectionValue = Copyable & ImplicitlyDestructible
comptime CollectionKey = Copyable & ImplicitlyDestructible & Hashable & Equatable


@fieldwise_init
struct EmptyCollectionError(TrivialRegisterPassable, Writable):
    def write_to(self, mut writer: Some[Writer]):
        writer.write("EmptyCollectionError")


trait Collection(
    ImplicitlyCopyable,
    Defaultable,
    Sized,
    Boolable,
):
    comptime T: CollectionValue

    def __bool__(self) -> Bool:
        return len(self) > 0


trait Sequence(Collection, Iterable):
    ...


trait Stack(Collection):
    comptime TopDownIteratorType[iterable_origin: Origin[mut=False]]: Iterator

    def __init__(out self, var list: List[Self.T]):
        """
        Initialize the stack from a List representing the elements in _insertion_ order. That means
        the first element of the list will be at the bottom of the stack and the last element at
        the top. In particular, since stack iteration goes from top to bottom, iterating over
        the resulting stack corresponds to the reverse List.
        """
        ...

    def push(self, var value: Self.T) -> Self:
        ...

    def pop(self) raises EmptyCollectionError -> Tuple[Self.T, Self]:
        ...

    def top(self) raises EmptyCollectionError -> Self.T:
        ...

    def iter_top_down(ref self) -> Self.TopDownIteratorType[origin_of(self)]:
        ...


trait BottomUpIterableStack(Stack):
    comptime BottomUpIteratorType[iterable_origin: Origin[mut=False]]: Iterator

    def iter_bottom_up(ref self) -> Self.BottomUpIteratorType[origin_of(self)]:
        ...


trait Queue(Collection):
    def __init__(out self, var list: List[Self.T]):
        """
        Initialize the queue from a List representing the elements in _insertion_ order. That means
        the first element of the list will be at the front of the queue and the last element at
        the back. If the Queue implementation is Iterable, iteration over the queue goes in the same
        order as iteration over the provided list.
        """
        ...

    def push(self, var value: Self.T) -> Self:
        ...

    def pop(self) raises EmptyCollectionError -> Tuple[Self.T, Self]:
        ...

    def front(self) raises EmptyCollectionError -> Self.T:
        ...


trait IterableQueue(Queue, Sequence):
    ...