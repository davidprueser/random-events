# distutils: language = c++
# distutils: sources = src/random_events/interval_cpp.cpp
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

    def __cinit__(self, ):
        self.si_ = CPPSimpleInterval()

    def __init__(self, float lower = 0, float upper = 0, int left = Bound.OPEN, int right = Bound.OPEN):
        """
        Initializes the interval.
        :param lower: The lower bound of the interval.
        :param upper: The upper bound of the interval.
        :param left: The left bound of the interval.
        :param right: The right bound of the interval.
        """
        self.si_.lower = lower
        self.si_.upper = upper
        self.si_.left = <BorderType>left
        self.si_.right = <BorderType>right

    def __dealloc__(self):
        pass
        # del self.si_

    cdef CPPSimpleIntervalPtr_t as_cpp_simple_interval(self):
        return make_shared[CPPSimpleInterval](self.si_)

    def __hash__(self):
        return hash((self.si_.lower, self.si_.upper, self.si_.left,
                     self.si_.right))

    def __lt__(self, SimpleInterval other):
        if self.si_.lower < other.si_.lower:
            return self.si_.upper < other.si_.upper
        return self.si_.lower < other.si_.lower

    def __repr__(self):
        return AbstractSimpleSet.to_string(self)

    def __str__(self):
        return AbstractSimpleSet.to_string(self)

    cpdef Interval as_composite_set(self):
        return Interval(self)

    cpdef bint is_empty(self) except *:
        return self.si_.is_empty()

    cpdef bint is_singleton(self):
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """
        return self.si_.is_singleton()

    cdef SimpleInterval _from_cpp_si(self, CPPSimpleIntervalPtr_t si):
        cdef SimpleInterval sio = SimpleInterval.__new__(SimpleInterval)
        sio.si_ = si.get()[0]
        return sio

    cdef _from_cpp_si_set(self, SimpleIntervalSetPtr_t si):
        cdef set[SimpleInterval] py_simple_intervals = set[SimpleInterval]()
        for simple_interval in si.get()[0]:
            sio = self._from_cpp_si(simple_interval)
            sio.si_ = simple_interval.get()[0]
            py_simple_intervals.add(sio)
        py_sorted_simple_intervals = SortedSet(py_simple_intervals)
        return py_sorted_simple_intervals

    cpdef SimpleInterval intersection_with_cpp(self, SimpleInterval other):
        return self._from_cpp_si(self.si_.intersection_with(make_shared[CPPSimpleInterval](other.si_)))

    cpdef complement_cpp(self):
        return self._from_cpp_si_set(self.si_.complement())


    cpdef bint contains(self, float item) except *:
        return self.si_.contains(item)

    # can be used if bound is a c object not a python class
    cdef str non_empty_to_string(self):
        return self.si_.non_empty_to_string().decode('utf-8', 'replace')

    cpdef float center(self):
        """
        :return: The center point of the interval
        """
        return ((self.si_.lower + self.si_.upper) / 2) + self.si_.lower

class SimpleIntervalPy(SubclassJSONSerializer, SimpleInterval):

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), 'lower': self.si_.lower, 'upper': self.si_.upper, 'left': Bound.get_name(self.si_.left),
                'right': Bound.get_name(self.si_.right)}
    @classmethod
    def _from_json(cls, data: Dict[str, Any]) -> Self:
        return cls(data['lower'], data['upper'], Bound[data['left']], Bound[data['right']])


cdef class Interval(AbstractCompositeSet):
    def __cinit__(self):
        self.i_ = new CPPInterval()

    def __init__(self, *simple_sets_py):
        self.simple_sets_py = SortedSet(simple_sets_py)
        cdef SimpleInterval simple_set
        for simple_set in self.simple_sets_py:
            self.i_.simple_sets.get().insert(simple_set.as_cpp_simple_interval())

    def __dealloc__(self):
        del self.i_

    def __eq__(self, Interval other):
        return self.i_ == other.i_

    cdef Interval _from_cpp_interval(self, CPPIntervalPtr_t interval):
        cdef Interval io = Interval.__new__(Interval)
        io.i_ = interval.get()
        return io

    cdef SimpleInterval _from_cpp_si(self, CPPSimpleIntervalPtr_t si):
        cdef SimpleInterval sio = SimpleInterval.__new__(SimpleInterval)
        sio.si_ = si.get()[0]
        return sio

    cdef _from_cpp_si_set(self, SimpleIntervalSetPtr_t si):
        py_simple_intervals = SortedSet[SimpleInterval]()
        for simple_interval in si.get()[0]:
            sio = self._from_cpp_si(simple_interval)
            sio.si_ = simple_interval.get()[0]
            py_simple_intervals.add(sio)
        return py_simple_intervals


    cpdef Interval simplify(self):
        return self._from_cpp_interval(self.i_.simplify())

    cpdef Interval new_empty_set(self):
        return Interval()

    cpdef Interval complement_if_empty(self):
        return Interval([SimpleInterval(float('-inf'), float('inf'), Bound.OPEN, Bound.OPEN)])

    cpdef bint is_singleton(self):
        """
        :return: True if the interval is a singleton (contains only one value), False otherwise.
        """

        if self.i_.simple_sets.get().size() == 1:
            first_elem = self._from_cpp_si_set(self.i_.simple_sets)[0]
            return first_elem.is_singleton()

        return False

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
