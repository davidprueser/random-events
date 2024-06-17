import dataclasses

from random_events.interval import Bound
from sigma_algebra import AbstractSimpleSet

@dataclasses.dataclass
cdef class SimpleInterval:
    cdef public lower
    cdef public upper
    cdef Bound left
    cdef Bound right
    cpdef SimpleInterval intersection_with(self, SimpleInterval other)
    cpdef bint is_empty(self) except *
    cpdef bint contains(self, float item) except *
    # cpdef Interval as_composite_set(self)
    cpdef bint is_singleton(self)
    cpdef float center(self)

# cdef class Interval:
#