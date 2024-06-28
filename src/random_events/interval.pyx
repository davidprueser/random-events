from __future__ import annotations
from sortedcontainers import SortedSet
from typing_extensions import Dict, Any, Self
from random_events.utils import SubclassJSONSerializer

cdef class Bound:
    OPEN = 0
    CLOSED = 1

    @classmethod
    def invert(cls, value):
        return Bound.CLOSED if value == Bound.OPEN else Bound.OPEN


    @classmethod
    def intersect(cls, first, Bound second):
        """
        Intersect with another border

        :param second: The other border
        :return: The intersection of the two borders
        """
        return Bound.OPEN if first == Bound.OPEN or second == Bound.OPEN else Bound.CLOSED

    @classmethod
    def _names(cls):
        return {k for k, v in cls.__dict__.items() if not k.startswith('_')}

    @classmethod
    def get_name(cls, int value):
        for name, val in cls.__dict__.items():
            if val == value and not name.startswith('_'):
                return name
        return None

cdef class SimpleInterval(AbstractSimpleSet):
    """
    Represents a simple interval.
    """

    def __cinit__(self, lower: float = 0, upper: float = 0, left: int = Bound.OPEN, right: int = Bound.OPEN):
        """
        Initializes the interval.
        :param lower: The lower bound of the interval.
        :param upper: The upper bound of the interval.
        :param left: The left bound of the interval.
        :param right: The right bound of the interval.
        """
        self._simple_interval = CPPSimpleInterval(lower, upper, left, right)

    def __hash__(self):
        return hash((self._simple_interval.lower, self._simple_interval.upper, self._simple_interval.left,
                     self._simple_interval.right))

    def __lt__(self, SimpleInterval other):
        return self._simple_interval < other._simple_interval

    def __repr__(self):
        return AbstractSimpleSet.to_string(self)

    def __str__(self):
        return AbstractSimpleSet.to_string(self)

    cpdef Interval as_composite_set(self):
        return Interval(self)

    cpdef bint is_empty(self) except *:
        return self._simple_interval.lower > self._simple_interval.upper or (
                self._simple_interval.lower == self._simple_interval.upper and (self._simple_interval.left == Bound.OPEN
                                                                                or self._simple_interval.right ==
                                                                                Bound.OPEN))

    cpdef bint is_singleton(self) except *:
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """
        return (self._simple_interval.lower == self._simple_interval.upper and self._simple_interval.left == Bound.CLOSED
                and self._simple_interval.right == Bound.CLOSED)

    cpdef SimpleInterval intersection_with_si(self, SimpleInterval other):

        # create new limits for the intersection
        cdef float new_lower = max(self._simple_interval.lower, other._simple_interval.lower)
        cdef float new_upper = min(self._simple_interval.upper, other._simple_interval.upper)

        # if the new limits are not valid, return an empty interval
        if new_lower > new_upper:
            return SimpleInterval()

        # create the new left bound
        if self._simple_interval.lower == other._simple_interval.lower:
            new_left: int = Bound.intersect(self._simple_interval.left, other._simple_interval.left)
        else:
            new_left: int = self._simple_interval.left if self._simple_interval.lower > other._simple_interval.lower \
                else other._simple_interval.left

        # create the new right bound
        if self._simple_interval.upper == other._simple_interval.upper:
            new_right: int = Bound.intersect(self._simple_interval.right, other._simple_interval.right)
        else:
            new_right: int = self._simple_interval.right if self._simple_interval.upper < other._simple_interval.upper \
                else other._simple_interval.right

        return SimpleInterval(new_lower, new_upper, new_left, new_right)

    cdef cppset[CPPSimpleInterval] complement_si(self):
        cdef cppset[CPPSimpleInterval] result

        # if the interval is empty
        if self.is_empty():
            # return the real line
            result.insert(CPPSimpleInterval(float('-inf'), float('inf'), Bound.OPEN, Bound.OPEN))
            return result

        result = cppset[CPPSimpleInterval]()

        # if this is the real line
        if self._simple_interval.lower == float('-inf') and self._simple_interval.upper == float('inf'):
            # return the empty set
            return result

        # if the lower bound is not negative infinity
        if self._simple_interval.lower > float('-inf'):
            # add the interval from minus infinity to the lower bound
            result.insert(CPPSimpleInterval(float('-inf'), self._simple_interval.lower, Bound.OPEN, Bound.invert(self._simple_interval.left)))

        # if the upper bound is not positive infinity
        if self._simple_interval.upper < float('inf'):
            # add the interval from the upper bound to infinity
            result.insert(CPPSimpleInterval(self._simple_interval.upper, float('inf'), Bound.invert(self._simple_interval.right), Bound.OPEN))

        return result

    cpdef bint contains(self, float item) except *:
        return (self.lower < item < self.upper or (self.lower == item and self.left == Bound.CLOSED) or (
                self.upper == item and self.right == Bound.CLOSED))

    # can be used if bound is a c object not a python class
    def non_empty_to_string(self):
        left_bracket = '[' if self.left == Bound.CLOSED else '('
        right_bracket = ']' if self.right == Bound.CLOSED else ')'
        return f'{left_bracket}{self.lower}, {self.upper}{right_bracket}'
        # cdef left_bracket = '[' if self.left == Bound.CLOSED else '('
        # cdef right_bracket = ']' if self.right == Bound.CLOSED else ')'
        # return printf("%s%f, %f%s", left_bracket, self.lower, self.upper, right_bracket)

    cpdef float center(self):
        """
        :return: The center point of the interval
        """
        return ((self.lower + self.upper) / 2) + self.lower

class SimpleIntervalPy(SubclassJSONSerializer, SimpleInterval):

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), 'lower': self.lower, 'upper': self.upper, 'left': Bound.get_name(self.left),
                'right': Bound.get_name(self.right)}
    @classmethod
    def _from_json(cls, data: Dict[str, Any]) -> Self:
        return cls(data['lower'], data['upper'], Bound[data['left']], Bound[data['right']])


cdef class Interval(AbstractCompositeSet):

    cpdef Interval simplify(self):

        # if the set is empty, return it
        if self.is_empty():
            return self

        # initialize the result
        result: Interval = self.simple_sets[0].as_composite_set()

        # iterate over the simple sets
        for current_simple_interval in self.simple_sets[1:]:

            # get the last element in the result
            last_simple_interval : SortedSet[SimpleInterval] = result.simple_sets[-1]

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


cpdef Interval open(float left, float right):
    """
    Creates an open interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The open interval.
    """
    return SimpleInterval(left, right, Bound.OPEN, Bound.OPEN).as_composite_set()


cpdef Interval closed(float left, float right):
    """
    Creates a closed interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The closed interval.
    """
    return SimpleInterval(left, right, Bound.CLOSED, Bound.CLOSED).as_composite_set()


cpdef Interval open_closed(float left, float right):
    """
    Creates an open-closed interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The open-closed interval.
    """
    return SimpleInterval(left, right, Bound.OPEN, Bound.CLOSED).as_composite_set()


cpdef Interval closed_open(float left, float right):
    """
    Creates a closed-open interval.
    :param left: The left bound of the interval.
    :param right: The right bound of the interval.
    :return: The closed-open interval.
    """
    return SimpleInterval(left, right, Bound.CLOSED, Bound.OPEN).as_composite_set()


cpdef Interval singleton(float value):
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
