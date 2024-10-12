# distutils: language = c++

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
    def intersect(cls, first, second):
        """
        Intersect with another border

        :param first: The first border
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

    def get_value(self):
        for name, val in self.__dict__.items():
            if name == name and not name.startswith('_'):
                return val
        return None


cdef class SimpleInterval(AbstractSimpleSet):
    """
    Represents a simple interval.
    """

    def __cinit__(self, float lower = 0, float upper = 0, int left = Bound.OPEN, int right = Bound.OPEN):
        self.lower = lower
        self.upper = upper
        self.left = left
        self.right = right

        self.cpp_simple_interval_object = new CPPSimpleInterval(lower, upper, <BorderType> left, <BorderType> right)
        self.cpp_object = self.cpp_simple_interval_object
        self.json_serializer = SimpleIntervalJSON(self)

    cdef const CPPAbstractSimpleSetPtr_t as_cpp_simple_set(self):
        return shared_ptr[CPPAbstractSimpleSet](self.cpp_object)

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

    cpdef Interval as_composite_set(self):
        return Interval(self)

    cpdef bint is_empty(self) except *:
        return self.cpp_object.is_empty()

    cpdef bint is_singleton(self):
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """
        return self.cpp_simple_interval_object.is_singleton()

    cdef AbstractSimpleSet from_cpp_si(self, CPPAbstractSimpleSetPtr_t simple_set):
        # Cast the CPPAbstractSimpleSet pointer to CPPSimpleInterval pointer
        cdef CPPSimpleInterval * cpp_interval = <CPPSimpleInterval *> simple_set.get()

        # Make sure that cpp_interval is not NULL (i.e., ensure the cast was valid)
        if cpp_interval is not NULL:
            # Create and return a new SimpleInterval Python object
            return SimpleInterval(cpp_interval.lower, cpp_interval.upper, cpp_interval.left, cpp_interval.right)
        else:
            raise ValueError("Invalid CPPSimpleInterval pointer.")

    cdef set[SimpleInterval] from_cpp_simple_set_set(self, SimpleSetSetPtr_t simple_set_set):
        cdef set[SimpleInterval] py_simple_sets = set[SimpleInterval]()
        for simple_set in simple_set_set.get()[0]:
            sio = self.from_cpp_si(simple_set)
            py_simple_sets.add(sio)
        return py_simple_sets

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other):
        return self.from_cpp_si(self.cpp_object.intersection_with(shared_ptr[CPPAbstractSimpleSet](other.cpp_object)))

    cpdef complement(self):
        return self.from_cpp_simple_set_set(self.cpp_object.complement())

    cpdef bint contains(self, float item) except *:
        return self.cpp_simple_interval_object.contains(item)

    cpdef str non_empty_to_string(self):
        left_bracket = '[' if self.cpp_simple_interval_object.left == Bound.CLOSED else '('
        right_bracket = ']' if self.cpp_simple_interval_object.right == Bound.CLOSED else ')'
        return f'{left_bracket}{self.cpp_simple_interval_object.lower}, {self.cpp_simple_interval_object.upper}{right_bracket}'

    cpdef float center(self):
        """
        :return: The center point of the interval
        """
        return ((self.cpp_simple_interval_object.lower + self.cpp_simple_interval_object.upper) / 2) + self.cpp_simple_interval_object.lower

    def to_json(self):
        return self.json_serializer.to_json()


class SimpleIntervalJSON(SubclassJSONSerializer):
    def __init__(self, si: SimpleInterval):
        self.si = si

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), 'lower': self.si.lower, 'upper': self.si.upper, 'left': Bound.get_name(self.si.left),
                'right': Bound.get_name(self.si.right)}

    @classmethod
    def _from_json(cls, data: Dict[str, Any]) -> Self:
        left_val = getattr(Bound, data['left'])
        right_val = getattr(Bound, data['right'])
        return SimpleInterval(data['lower'], data['upper'], left_val, right_val)


cdef class Interval(AbstractCompositeSet):

    def __cinit__(self, *simple_sets_py):
        self.simple_intervals = []
        self.json_serializer = IntervalJSON(self)
        self.simple_sets_py = SortedSet(simple_sets_py)
        self.cpp_object = new CPPInterval()

        cdef SimpleInterval simple_set
        for simple_set in self.simple_sets_py:
            self.simple_intervals.append(simple_set)  # Keep reference
            self.cpp_object.simple_sets.get().insert(simple_set.as_cpp_simple_set())

    # def __dealloc__(self):
    #     print("Deallocating Interval")
    #     del self.cpp_object

    # cdef const SimpleSetSetPtr_t as_cpp_composite_set(self):
    #     for simple_set in self.simple_sets_py:
    #         self.cpp_object.simple_sets.get().insert(<const CPPAbstractSimpleSetPtr_t> simple_set.as_cpp_simple_set())
    #     return self.cpp_object.simple_sets

    cdef AbstractSimpleSet from_cpp_si(self, CPPAbstractSimpleSetPtr_t simple_set):
        # Cast the CPPAbstractSimpleSet pointer to CPPSimpleInterval pointer
        cdef CPPSimpleInterval * cpp_interval = <CPPSimpleInterval *> simple_set.get()

        # Make sure that cpp_interval is not NULL (i.e., ensure the cast was valid)
        if cpp_interval is not NULL:
            # Create and return a new SimpleInterval Python object
            return SimpleInterval(cpp_interval.lower, cpp_interval.upper, cpp_interval.left, cpp_interval.right)
        else:
            raise ValueError("Invalid CPPSimpleInterval pointer.")

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set):
        cdef CPPInterval * cpp_interval = <CPPInterval *> composite_set.get()

        if cpp_interval is not NULL:
            simple_intervals = self.from_cpp_composite_set_set(cpp_interval.simple_sets)
            return Interval(*simple_intervals)
        else:
            raise ValueError("Invalid CPPInterval pointer.")

    cdef from_cpp_composite_set_set(self, SimpleSetSetPtr_t composite_set):
        cdef list py_simple_sets = []  # Initialize an empty list
        for simple_set in composite_set.get()[0]:  # Iterate over the simple sets
            sio = self.from_cpp_si(simple_set)  # Convert C++ SimpleSet to Python SimpleInterval
            py_simple_sets.append(sio)  # Append to the list
        return py_simple_sets  # Return the list of SimpleInt

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
        return self.cpp_interval_object.is_singleton()

    def to_json(self):
        self.json_serializer.to_json()


class IntervalJSON(SubclassJSONSerializer):
    def __init__(self, i: Interval):
        self.i = i
    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), "simple_sets": [simple_set.to_json() for simple_set in self.i.simple_sets_py]}

    @classmethod
    def _from_json(cls, data: Dict[str, Any]) -> Self:
        return cls(*[AbstractSimpleSetJSON.from_json(simple_set) for simple_set in data["simple_sets"]])


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
