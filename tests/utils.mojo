from std.reflection import *
from immu.traits import *


@fieldwise_init
struct assert_raises_custom[ErrorT: AnyType](ImplicitlyCopyable):
    def __enter__(self) -> Self:
        return self

    def __exit__(self) raises:
        comptime expected_err = get_type_name[Self.ErrorT]()
        raise "Expected error of type '" + expected_err + "' but no error was raised"

    def __exit__[RaisedErrorT: AnyType](self, err: RaisedErrorT) -> Bool:
        comptime expected_err = get_type_name[Self.ErrorT]()
        comptime raised_err = get_type_name[RaisedErrorT]()

        if raised_err == expected_err:
            return True

        print("Expected error of type", expected_err, "but got error of type", raised_err)
        return False


def noop_implicitly_copyable[T: ImplicitlyCopyable](t: T): pass
def noop_defaultable[T: Defaultable](t: T): pass
def noop_sized[T: Sized](t: T): pass
def noop_booleable[T: Boolable](t: T): pass
def noop_collection[T: Collection](t: T): pass
def noop_iterable[T: Iterable](t: T): pass
def noop_sequence[T: Sequence](t: T): pass
def noop_stack[T: Stack](t: T): pass
def noop_bottom_up_iterable_stack[T: BottomUpIterableStack](t: T): pass
def noop_queue[T: Queue](t: T): pass
def noop_iterable_queue[T: IterableQueue](t: T): pass