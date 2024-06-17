from __future__ import annotations
from enum import Enum
from dataclasses import dataclass
from typing import Dict, Any

from sortedcontainers import SortedSet
from typing_extensions import Self

# from sigma_algebra import AbstractCompositeSet

cpdef enum Bound:
    CLOSED = 0
    OPEN = 1

cpdef Bound invert(self):
    return Bound.CLOSED if self == Bound.OPEN else Bound.OPEN

cpdef Bound intersect(first: Bound, second: Bound):
    """
    Intersect with another border

    :param first: The first border
    :param second: The other border
    :return: The intersection of the two borders
    """
    return Bound.OPEN if first == Bound.OPEN or second == Bound.OPEN else Bound.CLOSED


@dataclass
cdef class SimpleInterval:
    """
    Represents a simple interval.
    """

    cdef public lower
    """
    The lower bound of the interval.
    """

    cdef public upper
    """
    The upper bound of the interval.
    """

    left: Bound = Bound.OPEN
    """
    The bound type of the lower bound.
    """

    right: Bound = Bound.OPEN
    """
    The bound type of the upper bound.
    """

    cpdef __hash__(self):
        return hash((self.lower, self.upper, self.left, self.right))

    def __lt__(self, other: Self):
        if self.lower == other.lower:
            return self.upper < other.upper
        return self.lower < other.lower

    # def __repr__(self):
    #     return AbstractSimpleSet.to_string(self)
    #
    # def __str__(self):
    #     return AbstractSimpleSet.to_string(self)

    # cpdef Interval as_composite_set(self):
    #     return Interval(self)

    cpdef bint is_empty(self) except *:
        return self.lower > self.upper or (
                self.lower == self.upper and (self.left == Bound.OPEN or self.right == Bound.OPEN))

    cpdef bint is_singleton(self):
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """
        return self.lower == self.upper and self.left == Bound.CLOSED and self.right == Bound.CLOSED

    cpdef SimpleInterval intersection_with(self, SimpleInterval other):

        # create new limits for the intersection
        cdef float new_lower = max(self.lower, other.lower)
        cdef float new_upper = min(self.upper, other.upper)

        # if the new limits are not valid, return an empty interval
        if new_lower > new_upper:
            return SimpleInterval()

        # create the new left bound
        if self.lower == other.lower:
            new_left: Bound = intersect(self.left, other.left)
        else:
            new_left: Bound = self.left if self.lower > other.lower else other.left

        # create the new right bound
        if self.upper == other.upper:
            new_right: Bound = intersect(self.right, other.right)
        else:
            new_right: Bound = self.right if self.upper < other.upper else other.right

        return SimpleInterval(new_lower, new_upper, new_left, new_right)

    # cpdef SortedSet complement(self):
    #
    #     # if the interval is empty
    #     if self.is_empty():
    #         # return the real line
    #         return SortedSet([SimpleInterval(float('-inf'), float('inf'), Bound.OPEN, Bound.OPEN)])
    #
    #     # initialize the result
    #     result = SortedSet()
    #
    #     # if this is the real line
    #     if self.lower == float('-inf') and self.upper == float('inf'):
    #         # return the empty set
    #         return result
    #
    #     # if the lower bound is not negative infinity
    #     if self.lower > float('-inf'):
    #         # add the interval from minus infinity to the lower bound
    #         result.add(SimpleInterval(float('-inf'), self.lower, Bound.OPEN, invert(self.left)))
    #
    #     # if the upper bound is not positive infinity
    #     if self.upper < float('inf'):
    #         # add the interval from the upper bound to infinity
    #         result.add(SimpleInterval(self.upper, float('inf'), invert(self.right), Bound.OPEN))
    #
    #     return result

    cpdef bint contains(self, float item) except *:
        return (self.lower < item < self.upper or (self.lower == item and self.left == Bound.CLOSED) or (
                self.upper == item and self.right == Bound.CLOSED))

    # cpdef str non_empty_to_string(self):
    #     left_bracket: str = '[' if self.left == Bound.CLOSED else '('
    #     right_bracket: str = ']' if self.right == Bound.CLOSED else ')'
    #     return f'{left_bracket}{self.lower}, {self.upper}{right_bracket}'

    # cpdef Dict[str, Any] to_json(self):
    #     return {**super().to_json(), 'lower': self.lower, 'upper': self.upper, 'left': self.left.name,
    #             'right': self.right.name}

    # @classmethod
    # cdef SimpleInterval _from_json(cls, data: Dict[str, Any]):
    #     return cls(data['lower'], data['upper'], Bound[data['left']], Bound[data['right']])

    cpdef float center(self):
        """
        :return: The center point of the interval
        """
        return ((self.lower + self.upper) / 2) + self.lower


cdef class Interval:
    simple_sets: SortedSet[SimpleInterval]

    cpdef Interval simplify(self):

        # if the set is empty, return it
        if self.is_empty():
            return self

        # initialize the result
        cdef Interval result = self.simple_sets[0].as_composite_set()

        # iterate over the simple sets
        for current_simple_interval in self.simple_sets[1:]:

            # get the last element in the result
            last_simple_interval: SortedSet[SimpleInterval] = result.simple_sets[-1]

            # if the borders are connected
            if (last_simple_interval.upper > current_simple_interval.lower or (
                    last_simple_interval.upper == current_simple_interval.lower and not (
                    last_simple_interval.right == Bound.OPEN and current_simple_interval.left == Bound.OPEN))):

                # extend the upper bound of the last element
                last_simple_interval.upper = current_simple_interval.upper
                last_simple_interval.right = current_simple_interval.right
            else:

                # add the current element to the result
                result.simple_sets.add(current_simple_interval)

        return result

    cpdef Interval new_empty_set(self):
        return Interval()

    cpdef Interval complement_if_empty(self):
        return Interval([SimpleInterval(float('-inf'), float('inf'), Bound.OPEN, Bound.OPEN)])

    cpdef bint is_singleton(self):
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """
        return len(self.simple_sets) == 1 and self.simple_sets[0].is_singleton()


cpdef Interval open(left: float, right: float):
    """
    Creates an open interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The open interval.
    """
    return SimpleInterval(left, right, Bound.OPEN, Bound.OPEN).as_composite_set()


cpdef Interval closed(left: float, right: float):
    """
    Creates a closed interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The closed interval.
    """
    return SimpleInterval(left, right, Bound.CLOSED, Bound.CLOSED).as_composite_set()


cpdef Interval open_closed(left: float, right: float):
    """
    Creates an open-closed interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The open-closed interval.
    """
    return SimpleInterval(left, right, Bound.OPEN, Bound.CLOSED).as_composite_set()


cpdef Interval closed_open(left: float, right: float):
    """
    Creates a closed-open interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The closed-open interval.
    """
    return SimpleInterval(left, right, Bound.CLOSED, Bound.OPEN).as_composite_set()


cpdef Interval singleton(value: float):
    """
    Creates a singleton interval.
    :param value: The value of the interval.
    :return: The singleton interval.
    """
    return SimpleInterval(value, value, Bound.CLOSED, Bound.CLOSED).as_composite_set()


cpdef Interval reals():
    """
    Creates the set of real numbers.
    :return: The set of real numbers.
    """
    return SimpleInterval(float('-inf'), float('inf'), Bound.OPEN, Bound.OPEN).as_composite_set()
