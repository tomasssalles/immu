from std.memory import ArcPointer
from std.os import abort
from std.collections import check_bounds
from immu.traits import CollectionValue, EmptyCollectionError, Vector
from immu._utils import bit_digits


struct _NodeRef[T: CollectionValue](Copyable):
    var ptr: ArcPointer[_Node[Self.T]]

    def __init__(out self, var ptr: ArcPointer[_Node[Self.T]]):
        self.ptr = ptr^


struct _Node[T: CollectionValue](Copyable):
    var value: Self.T
    var children_refs: List[_NodeRef[Self.T]]

    def __init__(out self, var value: Self.T, var children_refs: List[_NodeRef[Self.T]]):
        self.value = value^
        self.children_refs = children_refs^



struct _BTVForwardIterator[T: CollectionValue](ImplicitlyCopyable, Iterator, Iterable):
    comptime Element = Self.T

    comptime IteratorType[
        iterable_mut: Bool, //, iterable_origin: Origin[mut=iterable_mut]
    ]: Iterator = Self

    def __init__(out self):
        pass

    def __next__(mut self) raises StopIteration -> Self.Element:
        raise StopIteration()

    @always_inline
    def __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        return self.copy()

    @always_inline
    def bounds(self) -> Tuple[Int, Optional[Int]]:
        return (0, None)


struct _BTVBackwardIterator[T: CollectionValue](ImplicitlyCopyable, Iterator, Iterable):
    comptime Element = Self.T

    comptime IteratorType[
        iterable_mut: Bool, //, iterable_origin: Origin[mut=iterable_mut]
    ]: Iterator = Self

    def __init__(out self):
        pass

    def __next__(mut self) raises StopIteration -> Self.Element:
        raise StopIteration()

    @always_inline
    def __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        return self.copy()

    @always_inline
    def bounds(self) -> Tuple[Int, Optional[Int]]:
        return (0, None)


struct BitmapTrieVector[_T: CollectionValue, bits_per_level: Int where (bits_per_level > 0) = 5](Vector):
    """
    Persistent vector/list with random access to elements by index and iteration
    in both directions. Implemented using a high fan-out trie (with the default
    bits_per_level=5) with depth kept to a minimum.

    Basically all operations involve following/replacing paths inside the trie and
    therefore have complexities that depend on the trie's depth. In practice, with
    e.g. the default bits_per_level=5 and in a system where memory addresses have 64
    bits, the maximum depth that can be reached is 13 and, more importantly, realistic
    large instances with e.g. 1 million/billion/trillion elements would have depth
    4/6/8. This is still quite a bit more than what's required in a regular List, for
    example, and these Trie operations involve following pointers and making heap
    allocations. Nevertheless, we get:

    Effectively O(1) append, pop, __getitem__ and each iteration step in either
    direction.

    At the moment the interface is kept to the efficiently implemented fundamental
    operations only. In the future we might add many O(n) convenience methods such as
    insertion/deletion at any position, concatenation or __getitem__ with a slice.
    """
    comptime T = Self._T
    comptime _NodeT = _Node[Self.T]

    comptime IteratorType[
        iterable_mut: Bool, //, iterable_origin: Origin[mut=iterable_mut]
    ]: Iterator = _BTVForwardIterator[Self.T]

    comptime ReverseIteratorType[
        iterable_origin: Origin[mut=False]
    ]: Iterator = _BTVBackwardIterator[Self.T]

    var _maybe_root_ptr: Optional[ArcPointer[Self._NodeT]]
    var _len: Int

    def __init__(out self):
        self._maybe_root_ptr = None
        self._len = 0

    def __init__(out self, var list: List[Self.T]):
        v = Self()

        it = iter(list^)
        while True:
            try:
                v = v.append(next(it))
            except StopIteration:
                break

        self = v^

    def __len__(self) -> Int:
        return self._len

    def __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        return _BTVForwardIterator[Self.T]()

    def __reversed__(ref self) -> Self.ReverseIteratorType[origin_of(self)]:
        return _BTVBackwardIterator[Self.T]()

    def append(self, var value: Self.T) -> Self:
        new = Self()

        if not self._maybe_root_ptr:
            new._maybe_root_ptr = ArcPointer(_Node(value^, []))
            new._len = 1
            return new^

        ref root = self._maybe_root_ptr.value()[]
        new._maybe_root_ptr = ArcPointer(root.copy())

        new_element_idx = self._len
        digits = bit_digits[Self.bits_per_level](new_element_idx)
        node_ptr = UnsafePointer(to=new._maybe_root_ptr.value()[]).unsafe_origin_cast[MutExternalOrigin]()
        for level, digit in enumerate(digits):
            if level == len(digits) - 1:
                new_child = _Node(value^, [])
                node_ptr[].children_refs.append(_NodeRef[Self.T](ArcPointer(new_child^)))
                break
            
            # Most nodes have up to 2**bits_per_level children, one for each possible digit,
            # but the root only has up to (2**bits_per_level) - 1 children, because new_element_idx > 0
            # and so the most significant digit must be at least 1.
            child_idx = digit - 1 if level == 0 else digit

            ref child_ref = node_ptr[].children_refs[child_idx]
            child_ref.ptr = ArcPointer(child_ref.ptr[].copy())
            node_ptr = UnsafePointer(to=child_ref.ptr[]).unsafe_origin_cast[MutExternalOrigin]()

        new._len = self._len + 1
        return new^

    def pop(self) raises EmptyCollectionError -> Tuple[Self.T, Self]:
        if not self._maybe_root_ptr:
            raise EmptyCollectionError()

        new = Self()
        ref root = self._maybe_root_ptr.value()[]

        if self._len == 1:
            return (root.value.copy(), new^)

        new._maybe_root_ptr = ArcPointer(root.copy())
        new._len = self._len - 1

        element_to_pop_idx = self._len - 1
        digits = bit_digits[Self.bits_per_level](element_to_pop_idx)
        node_ptr = UnsafePointer(to=new._maybe_root_ptr.value()[]).unsafe_origin_cast[MutExternalOrigin]()
        for level, digit in enumerate(digits):
            if level == len(digits) - 1:
                value = node_ptr[].children_refs.pop().ptr[].value.copy()
                return (value^, new^)
            
            # Most nodes have up to 2**bits_per_level children, one for each possible digit,
            # but the root only has up to (2**bits_per_level) - 1 children, because element_to_pop_idx > 0
            # and so the most significant digit must be at least 1.
            child_idx = digit - 1 if level == 0 else digit

            ref child_ref = node_ptr[].children_refs[child_idx]
            child_ref.ptr = ArcPointer(child_ref.ptr[].copy())
            node_ptr = UnsafePointer(to=child_ref.ptr[]).unsafe_origin_cast[MutExternalOrigin]()

        abort("unreachable: corrupt trie structure in pop()")

    @always_inline
    def __getitem__(self, idx: Int) -> ref[self] Self.T:
        check_bounds(idx, len(self))

        digits = bit_digits[Self.bits_per_level](idx)
        node_ptr = UnsafePointer(to=self._maybe_root_ptr.value()[]).unsafe_origin_cast[MutExternalOrigin]()
        for level, digit in enumerate(digits):
            child_idx = digit - 1 if level == 0 else digit
            node_ptr = UnsafePointer(to=node_ptr[].children_refs[child_idx].ptr[]).unsafe_origin_cast[MutExternalOrigin]()
        return node_ptr[].value

    @always_inline
    def __getitem__(self, idx: IntLiteral) -> ref[self] Self.T:
        comptime assert IntLiteral[idx.value]() >= 0, "__getitem__ requires a non-negative value"
        return self[Int(idx)]

    @always_inline
    def __getitem__(self, idx: Some[Indexer]) -> ref[self] Self.T:
        return self[index(idx)]

    # TODO: Add method to assign a new value at a given index (within bounds)
    # TODO: Use a single instance in the init from a list and mutate it, to avoid the whole path copying for each list element.