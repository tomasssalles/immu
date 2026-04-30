from std.testing import *
from tests.utils import *
from immu.traits import EmptyCollectionError
from immu.queue import StacksQueue


def test_implemented_traits() raises:  # Just needs to compile
    q = StacksQueue[Int]()
    noop_implicitly_copyable(q)
    noop_defaultable(q)
    noop_sized(q)
    noop_booleable(q)
    noop_collection(q)
    noop_queue(q)

    
def test_push_and_pop() raises:
    q = StacksQueue[Int]()

    with assert_raises_custom[EmptyCollectionError]():
        _ = q.pop()

    q = q.push(42)
    q = q.push(99)
    q = q.push(7)
    (v, q) = q.pop()
    assert_equal(v, 42)
    q = q.push(101)
    (v, q) = q.pop()
    assert_equal(v, 99)
    (v, q) = q.pop()
    assert_equal(v, 7)
    q = q.push(-5)
    q = q.push(-51)
    (v, q) = q.pop()
    assert_equal(v, 101)
    (v, q) = q.pop()
    assert_equal(v, -5)
    (v, q) = q.pop()
    assert_equal(v, -51)
    
    with assert_raises_custom[EmptyCollectionError]():
        _ = q.pop()


def test_len_and_bool() raises:
    q = StacksQueue[Int]()
    assert_equal(len(q), 0)
    assert_false(q)

    q = q.push(42)
    assert_equal(len(q), 1)
    assert_true(q)

    q = q.push(99)
    q = q.push(7)
    assert_equal(len(q), 3)
    assert_true(q)

    _, q = q.pop()
    assert_equal(len(q), 2)
    assert_true(q)

    _, q = q.pop()
    _, q = q.pop()
    assert_equal(len(q), 0)
    assert_false(q)


def test_front() raises:
    q = StacksQueue[Int]()

    with assert_raises_custom[EmptyCollectionError]():
        _ = q.front()

    q = q.push(42)
    assert_equal(q.front(), 42)
    assert_equal(q.front(), 42)  # Doesn't pop
    assert_equal(len(q), 1)  # Doesn't pop

    q = q.push(99)
    q = q.push(7)
    q = q.push(101)
    assert_equal(q.front(), 42)

    _, q = q.pop()
    assert_equal(q.front(), 99)

    _, q = q.pop()
    assert_equal(q.front(), 7)

    q = q.push(-5)
    q = q.push(-6)
    _, q = q.pop()
    _, q = q.pop()
    assert_equal(q.front(), -5)

    _, q = q.pop()
    assert_equal(q.front(), -6)

    _, q = q.pop()

    with assert_raises_custom[EmptyCollectionError]():
        _ = q.front()


def test_from_list() raises:
    q = StacksQueue([1, 2, 3, 999, 7])
    assert_equal(len(q), 5)
    
    (v, q) = q.pop()
    assert_equal(v, 1)
    (v, q) = q.pop()
    assert_equal(v, 2)
    (v, q) = q.pop()
    assert_equal(v, 3)
    (v, q) = q.pop()
    assert_equal(v, 999)
    (v, q) = q.pop()
    assert_equal(v, 7)

    assert_false(q)


def test_immutable() raises:
    q0 = StacksQueue[Int]()
    q1 = q0.push(7)
    q2 = q1.push(42)
    q3a = q2.push(9)
    q3b = q2.push(11)
    v3c, q3c = q2.pop()
    v4a, q4a = q3a.pop()
    v5a, q5a = q4a.pop()
    v6a, _ = q5a.pop()
    v4b, q4b = q3b.pop()
    v5b, q5b = q4b.pop()
    v6b, _ = q5b.pop()

    # assert everything only after all the changes...
    assert_equal(len(q0), 0)
    assert_equal(len(q1), 1)
    assert_equal(q1.front(), 7)
    assert_equal(len(q2), 2)
    assert_equal(q2.front(), 7)
    assert_equal(len(q3a), 3)
    assert_equal(q3a.front(), 7)
    assert_equal(len(q3b), 3)
    assert_equal(q3b.front(), 7)
    assert_equal(v3c, 7)
    assert_equal(len(q3c), 1)
    assert_equal(q3c.front(), 42)
    assert_equal(v4a, 7)
    assert_equal(v5a, 42)
    assert_equal(v6a, 9)
    assert_equal(v4b, 7)
    assert_equal(v5b, 42)
    assert_equal(v6b, 11)


def main() raises: 
    TestSuite.discover_tests[__functions_in_module()]().run()