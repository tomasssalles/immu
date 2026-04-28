from std.testing import *
from tests.utils import *
from immu.collections_base import EmptyCollectionError
from immu.stack import COWStack


def test_implemented_traits() raises:  # Just needs to compile
    noop_with_collection_constraints(COWStack[Int]())


def test_can_call_api() raises:  # Just needs to compile
    s = COWStack[Int]()

    t: COWStack[Int] = s.push(42)  # push
    _: COWStack[Int].T = 7  # comptime T

    try:
        _: Tuple[Int, COWStack[Int]] = t.pop()  # pop
        _: Int = t.top()  # top
    except EmptyCollectionError:
        pass

    l = List[Int]()
    for v in t.iter_top_down():  # Iterable with Int values
        l.append(v)


def test_push_and_pop() raises:
    s = COWStack[Int]()

    with assert_raises_custom[EmptyCollectionError]():
        _ = s.pop()

    s = s.push(42)
    s = s.push(99)
    s = s.push(7)
    (v, s) = s.pop()
    assert_equal(v, 7)
    s = s.push(101)
    (v, s) = s.pop()
    assert_equal(v, 101)
    (v, s) = s.pop()
    assert_equal(v, 99)
    s = s.push(-5)
    s = s.push(-51)
    (v, s) = s.pop()
    assert_equal(v, -51)
    (v, s) = s.pop()
    assert_equal(v, -5)
    (v, s) = s.pop()
    assert_equal(v, 42)
    
    with assert_raises_custom[EmptyCollectionError]():
        _ = s.pop()


def test_len_and_bool() raises:
    s = COWStack[Int]()
    assert_equal(len(s), 0)
    assert_false(s)

    s = s.push(42)
    assert_equal(len(s), 1)
    assert_true(s)

    s = s.push(99)
    s = s.push(7)
    assert_equal(len(s), 3)
    assert_true(s)

    _, s = s.pop()
    assert_equal(len(s), 2)
    assert_true(s)

    _, s = s.pop()
    _, s = s.pop()
    assert_equal(len(s), 0)
    assert_false(s)


def test_top() raises:
    s = COWStack[Int]()

    with assert_raises_custom[EmptyCollectionError]():
        _ = s.top()

    s = s.push(42)
    assert_equal(s.top(), 42)
    assert_equal(s.top(), 42)  # Doesn't pop
    assert_equal(len(s), 1)  # Doesn't pop

    s = s.push(99)
    s = s.push(7)
    assert_equal(s.top(), 7)

    _, s = s.pop()
    assert_equal(s.top(), 99)


def test_from_list() raises:
    s = COWStack([1, 2, 3, 999, 7])
    assert_equal(len(s), 5)
    
    (v, s) = s.pop()
    assert_equal(v, 7)
    (v, s) = s.pop()
    assert_equal(v, 999)
    (v, s) = s.pop()
    assert_equal(v, 3)
    (v, s) = s.pop()
    assert_equal(v, 2)
    (v, s) = s.pop()
    assert_equal(v, 1)

    assert_false(s)


def test_immutable() raises:
    s0 = COWStack[Int]()
    s1 = s0.push(7)
    s2 = s1.push(42)
    s3a = s2.push(9)
    s3b = s2.push(11)
    v3c, s3c = s2.pop()
    v4, s4 = s3a.pop()

    # assert everything only after all the changes...
    assert_equal(len(s0), 0)
    assert_equal(len(s1), 1)
    assert_equal(s1.top(), 7)
    assert_equal(len(s2), 2)
    assert_equal(s2.top(), 42)
    assert_equal(len(s3a), 3)
    assert_equal(s3a.top(), 9)
    assert_equal(len(s3b), 3)
    assert_equal(s3b.top(), 11)
    assert_equal(v3c, 42)
    assert_equal(len(s3c), 1)
    assert_equal(s3c.top(), 7)
    assert_equal(v4, 9)
    assert_equal(len(s4), 2)


def test_iteration() raises:
    src_list = [1, 5, 7, 2, 9, 11, 3, 3, 42]
    s = COWStack(src_list.copy())
    assert_equal(s.top(), 42)
    
    list = List[Int]()
    for v in s.iter_top_down():
        list.append(v)
    list.reverse()

    assert_equal(list, src_list)


def main() raises: 
    TestSuite.discover_tests[__functions_in_module()]().run()