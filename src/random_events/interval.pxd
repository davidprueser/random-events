from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.simple_interval cimport (CPPSimpleInterval, CPPInterval, SimpleIntervalSet_t, SimpleIntervalSetPtr_t,
BorderType, CPPSimpleIntervalPtr_t)
from libcpp.set cimport set as cppset
from libc.stdio cimport printf
from libcpp.string cimport string
from libcpp.memory cimport make_shared, shared_ptr

cdef class SimpleInterval(AbstractSimpleSet):
    cdef CPPSimpleInterval si_

    cdef shared_ptr[CPPSimpleInterval] as_cpp_simple_interval(self)

    cpdef AbstractCompositeSet as_composite_set(self)

    # cpdef bint is_empty(self) except *

    cpdef bint is_singleton(self)

    cdef SimpleInterval _from_cpp_si(self, CPPSimpleIntervalPtr_t si)

    cdef set[SimpleInterval] _from_cpp_si_set(self, SimpleIntervalSetPtr_t si)

    cpdef SimpleInterval intersection_with_cpp(self, SimpleInterval other)

    cpdef set[SimpleInterval] complement_cpp(self)

    # cpdef bint contains(self, float item) except *

    cdef str non_empty_to_string(self)

    cpdef float center(self) except *

cdef class Interval(AbstractCompositeSet):
    cdef CPPInterval *i_

    # cpdef Interval simplify(self)

    cpdef Interval new_empty_set(self)

    cpdef Interval complement_if_empty(self)

    # cpdef bint is_singleton(self)
