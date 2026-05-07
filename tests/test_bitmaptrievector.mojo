from std.testing import *
from tests.utils import *
from immu.traits import EmptyCollectionError
from immu.vector import BitmapTrieVector


def test_implemented_traits() raises:  # Just needs to compile
    v = BitmapTrieVector[Int]()
    noop_implicitly_copyable(v)
    noop_defaultable(v)
    noop_sized(v)
    noop_booleable(v)
    noop_collection(v)
    noop_iterable(v)
    noop_sequence(v)
    noop_reversible_sequence(v)
    noop_vector(v)


def test_push_and_pop() raises:
    v = BitmapTrieVector[Int, bits_per_level=1]()

    with assert_raises_custom[EmptyCollectionError]():
        _ = v.pop()

    v = v.append(42)
    v = v.append(99)
    v = v.append(7)
    (n, v) = v.pop()
    assert_equal(n, 7)
    v = v.append(101)
    (n, v) = v.pop()
    assert_equal(n, 101)
    (n, v) = v.pop()
    assert_equal(n, 99)
    v = v.append(-5)
    v = v.append(-51)
    (n, v) = v.pop()
    assert_equal(n, -51)
    (n, v) = v.pop()
    assert_equal(n, -5)
    (n, v) = v.pop()
    assert_equal(n, 42)
    
    with assert_raises_custom[EmptyCollectionError]():
        _ = v.pop()


def test_len_and_bool() raises:
    v = BitmapTrieVector[Int, bits_per_level=1]()
    assert_equal(len(v), 0)
    assert_false(v)

    v = v.append(42)
    assert_equal(len(v), 1)
    assert_true(v)

    v = v.append(99)
    v = v.append(7)
    assert_equal(len(v), 3)
    assert_true(v)

    _, v = v.pop()
    assert_equal(len(v), 2)
    assert_true(v)

    _, v = v.pop()
    _, v = v.pop()
    assert_equal(len(v), 0)
    assert_false(v)


def test_getitem() raises:
    v = BitmapTrieVector[Int, bits_per_level=1]()

    v = v.append(42)
    assert_equal(v[0], 42)
    assert_equal(v[0], 42)  # Doesn't pop
    assert_equal(len(v), 1)  # Doesn't pop

    v = v.append(99)
    v = v.append(7)
    assert_equal(v[0], 42)
    assert_equal(v[1], 99)
    assert_equal(v[2], 7)

    _, v = v.pop()
    assert_equal(v[0], 42)
    assert_equal(v[1], 99)


def test_from_list() raises:
    v = BitmapTrieVector[bits_per_level=1]([1, 2, 3, 999, 7])
    assert_equal(len(v), 5)
    
    (n, v) = v.pop()
    assert_equal(n, 7)
    (n, v) = v.pop()
    assert_equal(n, 999)
    (n, v) = v.pop()
    assert_equal(n, 3)
    (n, v) = v.pop()
    assert_equal(n, 2)
    (n, v) = v.pop()
    assert_equal(n, 1)

    assert_false(v)


# TODO: Tests with lots of values, multiple levels
# TODO: Tests with small bits_per_level to force multiple levels even with manually appended values.

def main() raises: 
    TestSuite.discover_tests[__functions_in_module()]().run()