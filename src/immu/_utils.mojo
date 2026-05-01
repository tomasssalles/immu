from std.bit import bit_width                                                                                                                                                                                       
from std.math import ceildiv


def bit_digits[bits: Int where bits > 0](n: Int) -> List[Int]:
    """
    Compute the digits of n in base 2**bits, in big-endian order, with no leading zeros.
    0 is mapped to the empty list.
    """
    debug_assert(n >= 0, "bit_digits requires a non-negative value")

    if n == 0:
        return []

    # Example with bits=5 and n=35
    # n == 0b100011, bit_width(n) == 6, num_digits == ceil(6/5) == 2
    num_digits = ceildiv(bit_width(n), bits)
    result = List[Int](capacity=num_digits)

    # Continuing the example:
    # 1 << bits == 32 -> mask == 31 == 0b11111
    # shift == 5
    # First iteration: (n >> shift) & mask == (0b100011 >> 5) & 0b11111 == 0b1 & 0b11111 == 0b1 == 1
    # Second iteration: (n >> shift) & mask == (0b100011 >> 0) & 0b11111 == 0b100011 & 0b11111 == 0b11 == 3
    # Return: [1, 3]
    comptime mask = (1 << bits) - 1
    shift = (num_digits - 1) * bits
    for _ in range(num_digits):
        result.append((n >> shift) & mask)
        shift -= bits

    return result^


@always_inline
def bit_digits[bits: Int where bits > 0](n: IntLiteral) -> List[Int]:
    comptime assert IntLiteral[n.value]() >= 0, "bit_digits requires a non-negative value"
    return bit_digits[bits](Int(n))


@always_inline
def bit_digits[bits: Int where bits > 0](n: Some[Indexer]) -> List[Int]:
    return bit_digits[bits](index(n))