from std.collections.list import _ListIter
from std.memory import ArcPointer
from immu.collections_base import ImmuCollection, EmptyCollectionError, ImmuValue


trait Stack(ImmuCollection):
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

    def top(self) raises EmptyCollectionError -> ref[origin_of(self._list_ptr[])] Self.T:
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


struct _NodeRef[T: ImmuValue](Copyable):
    var ptr: ArcPointer[_Node[Self.T]]

    def __init__(out self, var ptr: ArcPointer[_Node[Self.T]]):
        self.ptr = ptr^


struct _Node[T: ImmuValue](Copyable):
    var value: Self.T
    var maybe_next_node_ref: Optional[_NodeRef[Self.T]]

    def __init__(out self, var value: Self.T, var maybe_next_node_ref: Optional[_NodeRef[Self.T]]):
        self.value = value^
        self.maybe_next_node_ref = maybe_next_node_ref^


struct _LinkedStackIter[T: ImmuValue](ImplicitlyCopyable, Iterator, Iterable):
    comptime Element = Self.T

    comptime IteratorType[
        iterable_mut: Bool, //, iterable_origin: Origin[mut=iterable_mut]
    ]: Iterator = Self

    var s: LinkedStack[Self.T]

    def __init__(out self, var s: LinkedStack[Self.T]):
        self.s = s^

    def __next__(mut self) raises StopIteration -> Self.Element:
        try:
            return self.s._mutate_pop()
        except EmptyCollectionError:
            raise StopIteration()

    @always_inline
    def __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        return self.copy()

    @always_inline
    def bounds(self) -> Tuple[Int, Optional[Int]]:
        return (len(self.s), {len(self.s)})


struct LinkedStack[_T: ImmuValue](Stack):
    """
    Stack implemented via a persistent singly-linked list.

    O(1) push and pop.

    Structure is maximally shared between different versions, minimizing the memory footprint,
    but the elements are not stored in contiguous memory.

    Can only be top-down iterated.
    """
    comptime T = Self._T
    comptime _NodeT = _Node[Self.T]

    comptime TopDownIteratorType[iterable_origin: Origin[mut=False]]: Iterator = _LinkedStackIter[Self.T]
    
    var _maybe_root_ptr: Optional[ArcPointer[Self._NodeT]]
    var _len: Int

    def __init__(out self):
        self._maybe_root_ptr = None
        self._len = 0

    def __init__(out self, var list: List[Self.T]):
        s = Self()

        it = iter(list^)
        while True:
            try:
                s = s.push(next(it))
            except StopIteration:
                break

        self = s^

    def push(self, var value: Self.T) -> Self:
        var maybe_next_node_ref: Optional[_NodeRef[Self.T]]
        if self._maybe_root_ptr:
            maybe_next_node_ref = _NodeRef(self._maybe_root_ptr.value())
        else:
            maybe_next_node_ref = None
        new_root = Self._NodeT(value=value^, maybe_next_node_ref=maybe_next_node_ref^)

        new = Self()
        new._maybe_root_ptr = ArcPointer(new_root^)
        new._len = self._len + 1
        return new^

    def _mutate_pop(mut self) raises EmptyCollectionError -> Self.T:
        if not self._maybe_root_ptr:
            raise EmptyCollectionError()

        ref root = self._maybe_root_ptr.value()[]

        if not root.maybe_next_node_ref:
            self._maybe_root_ptr = None
        else:
            self._maybe_root_ptr = root.maybe_next_node_ref.value().ptr
        
        self._len -= 1

        return root.value.copy()

    def pop(self) raises EmptyCollectionError -> Tuple[Self.T, Self]:
        new = self.copy()
        value = new._mutate_pop()
        return (value^, new^)

    def top(self) raises EmptyCollectionError -> ref[origin_of(self._maybe_root_ptr.value()[].value)] Self.T:
        if not self._maybe_root_ptr:
            raise EmptyCollectionError()

        return self._maybe_root_ptr.value()[].value

    def iter_top_down(ref self) -> Self.TopDownIteratorType[origin_of(self)]:
        return Self.TopDownIteratorType[origin_of(self)](self)

    def __len__(self) -> Int:
        return self._len