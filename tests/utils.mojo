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


def noop_implicitly_copyable(t: Some[ImplicitlyCopyable]): pass
def noop_defaultable(t: Some[Defaultable]): pass
def noop_sized(t: Some[Sized]): pass
def noop_booleable(t: Some[Boolable]): pass
def noop_collection(t: Some[Collection]): pass
def noop_iterable(t: Some[Iterable]): pass
def noop_sequence(t: Some[Sequence]): pass
def noop_reversible_sequence(t: Some[ReversibleSequence]): pass
def noop_stack(t: Some[Stack]): pass
def noop_bottom_up_iterable_stack(t: Some[BottomUpIterableStack]): pass
def noop_queue(t: Some[Queue]): pass
def noop_iterable_queue(t: Some[IterableQueue]): pass
def noop_vector(t: Some[Vector]): pass