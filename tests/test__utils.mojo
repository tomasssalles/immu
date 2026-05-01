from std.testing import *
from immu._utils import *


def test_bit_digits_0() raises:
    assert_equal(bit_digits[1](0), [])
    assert_equal(bit_digits[5](0), [])
    assert_equal(bit_digits[8](0), [])


def test_bit_digits_5_bits() raises:
    assert_equal(bit_digits[5](0), [])
    assert_equal(bit_digits[5](1), [1])
    assert_equal(bit_digits[5](7), [7])
    assert_equal(bit_digits[5](31), [31])
    assert_equal(bit_digits[5](32), [1, 0])
    assert_equal(bit_digits[5](33), [1, 1])
    assert_equal(bit_digits[5](42), [1, 10])
    assert_equal(bit_digits[5](32*32*32*5 + 32*32*17 + 32*9 + 23), [5, 17, 9, 23])
    assert_equal(bit_digits[5](32*32*32*32*5 + 32*32*17 + 32*9 + 23), [5, 0, 17, 9, 23])


def test_bit_digits_1_bit() raises:
    assert_equal(bit_digits[1](0), [])
    assert_equal(bit_digits[1](0b11), [1, 1])
    assert_equal(bit_digits[1](0b1001101101), [1, 0, 0, 1, 1, 0, 1, 1, 0, 1])
    assert_equal(bit_digits[1](0b1000), [1, 0, 0, 0])


def test_bit_digits_4_bits() raises:
    assert_equal(bit_digits[4](0), [])
    assert_equal(bit_digits[4](0x1234), [1, 2, 3, 4])
    assert_equal(bit_digits[4](0xabcd9876), [10, 11, 12, 13, 9, 8, 7, 6])
    assert_equal(bit_digits[4](0xfff), [15, 15, 15])


def test_bit_digits_1000_bits() raises:
    assert_equal(bit_digits[1000](0), [])
    assert_equal(bit_digits[1000](1), [1])
    assert_equal(bit_digits[1000](1234567890), [1234567890])


def main() raises: 
    TestSuite.discover_tests[__functions_in_module()]().run()