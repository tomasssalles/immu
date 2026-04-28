from std.collections.list import _ListIter
from std.memory import ArcPointer
from immu.collections_base import ImmuCollection, EmptyCollectionError, ImmuValue


trait Stack(ImmuCollection):
    comptime TopDownIteratorType[iterable_origin: Origin[mut=False]]: Iterator

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


struct COWStack[_T: ImmuValue](BottomUpIterableStack):
    """
    Copy-on-write stack that wraps a List object.

    O(n) push and pop.

    Each version stores its values efficiently in contiguous memory, and iteration is
    therefore efficient, but different versions share no common structure, so if 
    multiple versions exist simultaneously, each has a full copy of the data.
    """
    comptime T = Self._T

    comptime TopDownIteratorType[iterable_origin: Origin[mut=False]]: Iterator = _ListIter[Self.T, iterable_origin, False]
    comptime BottomUpIteratorType[iterable_origin: Origin[mut=False]]: Iterator = _ListIter[Self.T, iterable_origin, True]

    var _list_ptr: ArcPointer[List[Self.T]]

    def __init__(out self):
        self._list_ptr = ArcPointer(List[Self.T]())

    def __init__(out self, var list: List[Self.T]):
        """
        Initialize the stack from a List representing the elements in _insertion_ order. That means
        the first element of the list will be at the bottom of the stack and the last element at
        the top. In particular, since stack iteration goes from top to bottom, iterating over
        the resulting stack corresponds to the reverse List.
        """
        self._list_ptr = ArcPointer(list^)

    def _deepcopy(self) -> Self:
        return Self(self._list_ptr[].copy())

    def push(self, var value: Self.T) -> Self:
        new = self._deepcopy()
        new._list_ptr[].append(value^)
        return new^

    def pop(self) raises EmptyCollectionError -> Tuple[Self.T, Self]:
        if not self:
            raise EmptyCollectionError()

        new = self._deepcopy()
        value = new._list_ptr[].pop()
        return (value^, new^)

    def top(self) raises EmptyCollectionError -> ref[self._list_ptr] Self.T:
        if not self:
            raise EmptyCollectionError()

        ref list = self._list_ptr[]
        return list[len(list) - 1]

    def iter_top_down(ref self) -> Self.TopDownIteratorType[origin_of(self)]:
        return rebind[Self.TopDownIteratorType[origin_of(self)]](reversed(self._list_ptr[]))

    def iter_bottom_up(ref self) -> Self.BottomUpIteratorType[origin_of(self)]:
        return rebind[Self.BottomUpIteratorType[origin_of(self)]](iter(self._list_ptr[]))

    def __len__(self) -> Int:
        return len(self._list_ptr[])

    # TODO: Make tests generic