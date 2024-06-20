from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet

cpdef enum Bound:
    OPEN = 0
    CLOSED = 1

cdef Bound invert(self) except *

cdef Bound intersect(Bound first, Bound second) except *


cdef class SimpleInterval(AbstractSimpleSet):
    cdef public float lower
    """
    The lower bound of the interval.
    """

    cdef public float upper
    """
    The upper bound of the interval.
    """

    cdef Bound left
    """
    The bound type of the lower bound.
    """

    cdef Bound right
    """
    The bound type of the upper bound.
    """

    cpdef AbstractCompositeSet as_composite_set(self)

    cpdef bint is_empty(self) except *

    cpdef bint is_singleton(self) except *

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)

    cpdef complement(self)

    cpdef bint contains(self, float item) except *

    cpdef str non_empty_to_string(self)

    cpdef float center(self) except *

cdef class Interval(AbstractCompositeSet):

    cpdef Interval simplify(self)

    cpdef Interval new_empty_set(self)

    cpdef Interval complement_if_empty(self)

    cpdef bint is_singleton(self)
