# distutils: language = c++

from __future__ import annotations
from sortedcontainers import SortedSet
from typing_extensions import Dict, Any, Self
from random_events.utils import SubclassJSONSerializer
from random_events.sigma_algebra import AbstractSimpleSetJSON, AbstractCompositeSetJSON

cdef class Bound:
    OPEN = 0
    CLOSED = 1

    @classmethod
    def invert(cls, value):
        return Bound.CLOSED if value == Bound.OPEN else Bound.OPEN


    @classmethod
    def intersect(cls, first, second):
        """
        Intersect with another border

        :param first: The first border
        :param second: The other border
        :return: The intersection of the two borders
        """
        return Bound.OPEN if first == Bound.OPEN or second == Bound.OPEN else Bound.CLOSED

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

    def __init__(self, float lower = 0, float upper = 0, int left = Bound.OPEN, int right = Bound.OPEN):
        self.lower = lower
        self.upper = upper
        self.left = left
        self.right = right

        self.cpp_simple_interval_object = new CPPSimpleInterval(lower, upper, <BorderType> left, <BorderType> right)
        self.cpp_object = self.cpp_simple_interval_object
        self.json_serializer = SimpleIntervalJSON(self)

    def __hash__(self):
        return hash((self.lower, self.upper, self.left, self.right))

    def __lt__(self, SimpleInterval other):
        if self.lower == other.lower:
            return self.upper < other.upper
        return self.lower < other.lower

    def __eq__(self, SimpleInterval other):
        return self.lower == other.lower and self.upper == other.upper and self.left == other.left and self.right == other.right

    def __repr__(self):
        return AbstractSimpleSet.to_string(self)

    def __str__(self):
        return AbstractSimpleSet.to_string(self)

    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set):
        # Cast the CPPAbstractSimpleSet pointer to CPPSimpleInterval pointer
        cdef CPPSimpleInterval * cpp_interval = <CPPSimpleInterval *> simple_set.get()

        # Make sure that cpp_interval is not NULL (i.e., ensure the cast was valid)
        if cpp_interval is not NULL:
            # Create and return a new SimpleInterval Python object
            return SimpleInterval(cpp_interval.lower, cpp_interval.upper, cpp_interval.left, cpp_interval.right)
        else:
            raise ValueError("Invalid CPPSimpleInterval pointer.")

    cpdef Interval as_composite_set(self):
        return Interval(self)

    cpdef bint is_empty(self) except *:
        return self.cpp_object.is_empty()

    cpdef bint is_singleton(self):
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """
        return self.cpp_simple_interval_object.is_singleton()

    cpdef complement(self):
        return self.from_cpp_simple_set_set(self.cpp_object.complement())

    cpdef bint contains(self, item) except *:
        return self.cpp_simple_interval_object.contains(<float> item)

    cpdef str non_empty_to_string(self):
        left_bracket = '[' if self.cpp_simple_interval_object.left == Bound.CLOSED else '('
        right_bracket = ']' if self.cpp_simple_interval_object.right == Bound.CLOSED else ')'
        return f'{left_bracket}{self.cpp_simple_interval_object.lower}, {self.cpp_simple_interval_object.upper}{right_bracket}'

    cpdef float center(self):
        """
        :return: The center point of the interval
        """
        return ((self.cpp_simple_interval_object.lower + self.cpp_simple_interval_object.upper) / 2) + self.cpp_simple_interval_object.lower

    cpdef to_json(self):
        return self.json_serializer.to_json()


class SimpleIntervalJSON(AbstractSimpleSetJSON):
    def __init__(self, ss: SimpleInterval):
        self.ss = ss

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), 'lower': self.ss.lower, 'upper': self.ss.upper, 'left': Bound.get_name(self.ss.left),
                'right': Bound.get_name(self.ss.right)}

    @staticmethod
    def _from_json(data: Dict[str, Any]):
        left_val = getattr(Bound, data['left'])
        right_val = getattr(Bound, data['right'])
        return SimpleInterval(data['lower'], data['upper'], left_val, right_val)


cdef class Interval(AbstractCompositeSet):

    def __init__(self, *simple_sets):
        super().__init__(*simple_sets)
        self.json_serializer = IntervalJSON(self)
        self.cpp_object = new CPPInterval()

        cdef SimpleInterval simple_set
        for simple_set in self.simple_sets:
            self.cpp_object.simple_sets.get().insert(shared_ptr[CPPAbstractSimpleSet](simple_set.cpp_object))

    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set):
        cdef CPPSimpleInterval * cpp_interval = <CPPSimpleInterval *> simple_set.get()
        return SimpleInterval(cpp_interval.lower, cpp_interval.upper, cpp_interval.left, cpp_interval.right)

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set):
        cdef CPPInterval * cpp_interval = <CPPInterval *> composite_set.get()
        simple_intervals = self.from_cpp_composite_set_set(cpp_interval.simple_sets)
        return Interval(*simple_intervals)

    cpdef AbstractCompositeSet simplify(self):
        return self.from_cpp_composite_set(self.cpp_object.simplify())

    cpdef Interval new_empty_set(self):
        return Interval()

    cpdef Interval complement_if_empty(self):
        return Interval([SimpleInterval(float('-inf'), float('inf'), Bound.OPEN, Bound.OPEN)])

    cpdef bint is_singleton(self):
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """
        interval = <CPPInterval*> self.cpp_object
        return interval.is_singleton()

    cpdef to_json(self):
        return self.json_serializer.to_json()


class IntervalJSON(AbstractCompositeSetJSON):
    def __init__(self, composite_set: Interval):
        super().__init__(composite_set)

    def to_json(self) -> Dict[str, Any]:
        return super().to_json()

    @staticmethod
    def _from_json(data: Dict[str, Any]):
        return Interval(*[AbstractSimpleSetJSON.from_json(simple_set) for simple_set in data['simple_sets']])


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
