from random_events.interval import SimpleIntervalJSON
from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.interval_cpp cimport CPPSimpleInterval, CPPInterval, BorderType, CPPSimpleIntervalPtr_t, CPPIntervalPtr_t
from random_events.sigma_algebra_cpp cimport (CPPAbstractSimpleSet, CPPAbstractCompositeSet, CPPAbstractSimpleSetPtr_t,
CPPAbstractCompositeSetPtr_t, SimpleSetSet_t, SimpleSetSetPtr_t)
from libcpp.set cimport set as cppset
from libc.stdio cimport printf
from libcpp.string cimport string
from libcpp.memory cimport make_shared, shared_ptr


cdef class SimpleInterval(AbstractSimpleSet):
    cdef CPPSimpleInterval *cpp_simple_interval_object
    cdef public float lower
    cdef public float upper
    cdef public int left
    cdef public int right

    cdef const CPPAbstractSimpleSetPtr_t as_cpp_simple_set(self)

    cdef const SimpleSetSetPtr_t as_cpp_simple_set_set(self)

    cpdef bint is_empty(self) except *

    cpdef bint is_singleton(self)

    cdef AbstractSimpleSet from_cpp_si(self, CPPAbstractSimpleSetPtr_t simple_set)

    cdef set[SimpleInterval] from_cpp_simple_set_set(self, SimpleSetSetPtr_t simple_set_set)

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)

    cpdef complement(self)

    cpdef bint contains(self, item) except *

    cpdef str non_empty_to_string(self)

    cpdef float center(self) except *


cdef class Interval(AbstractCompositeSet):
    cdef CPPInterval *cpp_interval_object

    cdef AbstractSimpleSet from_cpp_si(self, CPPAbstractSimpleSetPtr_t simple_set)

    cdef const CPPAbstractCompositeSetPtr_t as_cpp_composite_set(self)

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set)

    cdef from_cpp_composite_set_set(self, SimpleSetSetPtr_t si)

    cpdef AbstractCompositeSet simplify(self)

    cpdef Interval new_empty_set(self)

    cpdef Interval complement_if_empty(self)

    cpdef bint is_singleton(self)
