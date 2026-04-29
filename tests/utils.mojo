from std.reflection import *
from immu.stack import Stack, BottomUpIterableStack


def noop_with_collection_constraints[
    C: ImplicitlyCopyable & Defaultable & Boolable & Sized
](value: C):
    pass


def noop_with_stack_constraint[C: Stack](value: C):
    pass


def noop_with_bottom_up_iterable_stack_constraint[C: BottomUpIterableStack](value: C):
    pass


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