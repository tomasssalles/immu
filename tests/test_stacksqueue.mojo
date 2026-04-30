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


def main() raises: 
    TestSuite.discover_tests[__functions_in_module()]().run()