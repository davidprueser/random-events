from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.simple_interval cimport CPPSimpleInterval, CPPAbstractSimpleSet
from libcpp.set cimport set as cppset

cdef class SimpleInterval(AbstractSimpleSet):
    cdef CPPSimpleInterval *si_

    cpdef AbstractCompositeSet as_composite_set(self)

    cpdef bint is_empty(self) except *

    cpdef bint is_singleton(self) except *

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)

    cdef cppset[CPPSimpleInterval] complement_cpp(self)

    cpdef bint contains(self, float item) except *

    # cpdef str non_empty_to_string(self)

    cpdef float center(self) except *

cdef class Interval(AbstractCompositeSet):

    cpdef Interval simplify(self)

    cpdef Interval new_empty_set(self)

    cpdef Interval complement_if_empty(self)

    cpdef bint is_singleton(self)
