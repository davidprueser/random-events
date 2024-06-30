from random_events.cpp_set_wrapper import SetWrapper
from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
# from random_events.simple_interval cimport CPPSimpleInterval
from libcpp.set cimport set as cppset

from random_events.simple_interval cimport CPPSimpleInterval, CPPBound

cdef class SimpleInterval(AbstractSimpleSet):
    cdef CPPSimpleInterval si_

    # cdef public float lower
    # """
    # The lower bound of the interval.
    # """
    #
    # cdef public float upper
    # """
    # The upper bound of the interval.
    # """
    #
    # cdef int left
    # """
    # The bound type of the lower bound.
    # """
    #
    # cdef int right
    # """
    # The bound type of the upper bound.
    # """

    # cdef SimpleInterval(self, double lower = 0, double upper = 0, int left = 0, int right = 0)

    cpdef AbstractCompositeSet as_composite_set(self)

    cpdef bint is_empty(self) except *

    cpdef bint is_singleton(self) except *

    cpdef SimpleInterval intersection_with_si(self, SimpleInterval other)

    cdef cppset[CPPSimpleInterval] complement_si(self)

    cpdef bint contains(self, float item) except *

    # cpdef str non_empty_to_string(self)

    cpdef float center(self) except *

cdef class Interval(AbstractCompositeSet):

    cpdef Interval simplify(self)

    cpdef Interval new_empty_set(self)

    cpdef Interval complement_if_empty(self)

    cpdef bint is_singleton(self)
