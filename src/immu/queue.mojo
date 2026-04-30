from immu.traits import CollectionValue, EmptyCollectionError, Queue
from immu.stack import LinkedStack


struct StacksQueue[_T: CollectionValue](Queue):
    """
    Persistent queue implemented by joining two persistent stacks at the bottom.

    O(1) push and amortized O(1) pop with linear worst-case.

    Cannot be iterated.
    """
    comptime T = Self._T
    comptime _StackT = LinkedStack[Self.T]

    var _front: Self._StackT
    var _back: Self._StackT

    def __init__(out self):
        self._front = Self._StackT()
        self._back = Self._StackT()

    def __init__(out self, var list: List[Self.T]):
        """
        Initialize the queue from a List representing the elements in _insertion_ order. That means
        the first element of the list will be at the front of the queue and the last element at
        the back. If the Queue implementation is Iterable, iteration over the queue goes in the same
        order as iteration over the provided list.
        """
        q = Self()

        it = iter(list^)
        while True:
            try:
                q = q.push(next(it))
            except StopIteration:
                break

        self = q^


    def push(self, var value: Self.T) -> Self:
        new = Self()
        if self._front or self._back:
            new._front = self._front.copy()
            new._back = self._back.push(value^)
        else:
            # If the queue is empty, push the value directly in the front.
            # Guaranteed invariant: If the queue is not empty, then the _front stack is not empty.
            new._front = self._front.push(value^)
        return new^

    def _mutating_shift_if_needed(mut self):
        # If the _front stack is empty and there are elements in the _back,
        # shift the entire _back stack to the _front, inverting the arrows.

        if self._front or (not self._back):
            return
        
        while True:
            try:
                v = self._back._mutating_pop()
            except EmptyCollectionError:
                break
            self._front = self._front.push(v^)

    def pop(self) raises EmptyCollectionError -> Tuple[Self.T, Self]:
        new = self.copy()
        # Here, we rely on the invariant: If the queue is not empty, then the _front stack is not empty.
        # So if popping the _front raises an EmptyCollectionError, that means the queue is completely
        # empty and we want the exception to propagate.
        value = new._front._mutating_pop()
        # Here, in case we just popped the only element that was in the _front stack, we want to shift
        # the back elements to the front in the new queue instance, in order to guarantee the invariant
        # above once more.
        new._mutating_shift_if_needed()
        return (value^, new^)

    def front(self) raises EmptyCollectionError -> ref[origin_of(self._front.top())] Self.T:
        # Here, we rely on the invariant: If the queue is not empty, then the _front stack is not empty.
        # So if the _front raises an EmptyCollectionError because it has no top, that means the queue is
        # completely empty and we want the exception to propagate.
        return self._front.top()

    def __len__(self) -> Int:
        return len(self._front) + len(self._back)