from immu.traits import CollectionValue, EmptyCollectionError, Queue, IterableQueue


struct StacksQueue[_T: CollectionValue](Queue):
    """
    Persistent queue implemented by joining two persistent stacks at the bottom.

    O(1) push and amortized O(1) pop with linear worst-case.

    Cannot be iterated.
    """
    comptime T = Self._T

    def __init__(out self):
        pass

    def __init__(out self, var list: List[Self.T]):
        """
        Initialize the queue from a List representing the elements in _insertion_ order. That means
        the first element of the list will be at the front of the queue and the last element at
        the back. If the Queue implementation is Iterable, iteration over the queue goes in the same
        order as iteration over the provided list.
        """
        pass

    def push(self, var value: Self.T) -> Self:
        return Self()

    def pop(self) raises EmptyCollectionError -> Tuple[Self.T, Self]:
        raise EmptyCollectionError()

    def front(self) raises EmptyCollectionError -> Self.T:
        raise EmptyCollectionError()

    def back(self) raises EmptyCollectionError -> Self.T:
        raise EmptyCollectionError()

    def __len__(self) -> Int:
        return 0