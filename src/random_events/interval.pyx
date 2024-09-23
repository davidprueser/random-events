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

    def __init__(self, float lower = 0, float upper = 0, int left = Bound.OPEN, int right = Bound.OPEN):
        self.cpp_simple_interval_object = new CPPSimpleInterval(lower, upper, <BorderType> left, <BorderType> right)
        self.cpp_object = <CPPAbstractSimpleSet*> self.cpp_simple_interval_object

    cdef const CPPAbstractSimpleSetPtr_t as_cpp_simple_set(self):
        return shared_ptr[CPPAbstractSimpleSet](self.cpp_object)

    # cdef const SimpleSetSetPtr_t as_cpp_simple_set_set(self):
    #     cdef SimpleSetSet_t simple_set_set = cppset[CPPAbstractSimpleSetPtr_t]()
    #     simple_set_set.insert(self.as_cpp_simple_set())
    #     return shared_ptr[SimpleSetSet_t](simple_set_set)

    def __hash__(self):
        return hash((self.cpp_simple_interval_object.lower, self.cpp_simple_interval_object.upper, self.cpp_simple_interval_object.left,
                     self.cpp_simple_interval_object.right))

    def __lt__(self, SimpleInterval other):
        return self.cpp_simple_interval_object < other.cpp_simple_interval_object

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

    @staticmethod
    cdef AbstractSimpleSet from_cpp_si(CPPAbstractSimpleSetPtr_t simple_set):
        cdef AbstractSimpleSet simple_set_new = SimpleInterval.__new__(SimpleInterval)
        simple_set_new.cpp_object = simple_set.get()
        return simple_set_new

    cdef from_cpp_simple_set_set(self, SimpleSetSetPtr_t simple_set_set):
        cdef set[SimpleInterval] py_simple_sets = set[SimpleInterval]()
        for simple_set in simple_set_set.get()[0]:
            sio = AbstractSimpleSet.from_cpp_si(simple_set)
            sio.cpp_object = simple_set.get()
            py_simple_sets.add(sio)
        py_sorted_simple_sets = SortedSet(py_simple_sets)
        return py_sorted_simple_sets

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other):
        return AbstractSimpleSet.from_cpp_si(self.cpp_object.intersection_with(shared_ptr[CPPAbstractSimpleSet](other.cpp_object)))

    cpdef complement(self):
        return self.from_cpp_simple_set_set(self.cpp_object.complement())


    cpdef bint contains(self, float item) except *:
        return self.cpp_simple_interval_object.contains(item)

    cdef str non_empty_to_string(self):
        return self.cpp_simple_interval_object.non_empty_to_string()[0].decode('utf-8', 'replace')

    cpdef float center(self):
        """
        :return: The center point of the interval
        """
        return ((self.cpp_simple_interval_object.lower + self.cpp_simple_interval_object.upper) / 2) + self.cpp_simple_interval_object.lower

class SimpleIntervalPy(SubclassJSONSerializer, SimpleInterval):

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), 'lower': self.cpp_simple_interval_object.lower, 'upper': self.cpp_simple_interval_object.upper, 'left': Bound.get_name(self.cpp_simple_interval_object.left),
                'right': Bound.get_name(self.cpp_simple_interval_object.right)}
    @classmethod
    def _from_json(cls, data: Dict[str, Any]) -> Self:
        return cls(data['lower'], data['upper'], Bound[data['left']], Bound[data['right']])


cdef class Interval(AbstractCompositeSet):

    def __cinit__(self):
        self.cpp_interval_object = new CPPInterval()

    def __init__(self, *simple_sets_py):
        cdef AbstractSimpleSet simple_set
        for simple_set in simple_sets_py:
            self.cpp_interval_object.simple_sets.get().insert(simple_set.as_cpp_simple_set())
        self.cpp_object = <CPPAbstractCompositeSet*> self.cpp_interval_object

    def __dealloc__(self):
        del self.cpp_interval_object

    def __eq__(self, Interval other):
        return self.cpp_interval_object == other.cpp_interval_object

    cdef const CPPAbstractCompositeSetPtr_t as_cpp_composite_set(self):
        return shared_ptr[CPPAbstractCompositeSet](self.cpp_object)

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set):
        cdef Interval interval = Interval.__new__(Interval)
        interval.cpp_object = composite_set.get()
        return interval

    cdef from_cpp_composite_set_set(self, SimpleSetSetPtr_t si):
        cdef set[SimpleInterval] py_simple_sets = set[SimpleInterval]()
        for simple_set in si.get()[0]:
            sio = AbstractSimpleSet.__new__(AbstractSimpleSet)
            sio.cpp_object = AbstractSimpleSet.from_cpp_si(simple_set)
            py_simple_sets.add(sio)
        py_sorted_simple_sets = SortedSet(py_simple_sets)
        return py_sorted_simple_sets

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

        # if self.i_.simple_sets.get().size() == 1:
        #     first_elem = self._from_cpp_si_set(self.i_.simple_sets)[0]
        #     return first_elem.is_singleton()
        #
        # return False
        return self.cpp_interval_object.is_singleton()

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
