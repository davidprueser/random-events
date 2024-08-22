from random_events.interval_cpp cimport (CPPSimpleInterval, CPPInterval, BorderType, CPPSimpleIntervalPtr_t, CPPIntervalPtr_t,)
from random_events.sigma_algebra_cpp cimport (CPPAbstractSimpleSet, CPPAbstractCompositeSet, CPPAbstractSimpleSetPtr_t,
CPPAbstractCompositeSetPtr_t, SimpleSetSet_t, SimpleSetSetPtr_t)
from libcpp.set cimport set as cppset
from libc.stdio cimport printf
from libcpp.string cimport string
from libcpp.memory cimport make_shared, shared_ptr

cdef class SimpleInterval:
    cdef CPPSimpleInterval *cpp_object

    cdef const CPPAbstractSimpleSetPtr_t as_cpp_simple_set(self)

    # cdef const SimpleSetSetPtr_t as_cpp_simple_set_set(self)
    cpdef Interval as_composite_set(self)

    cpdef bint is_empty(self) except *

    cpdef bint is_singleton(self)

    @staticmethod
    cdef SimpleInterval from_cpp_si(CPPAbstractSimpleSetPtr_t simple_set)

    @staticmethod
    cdef from_cpp_simple_set_set(SimpleSetSetPtr_t simple_set_set)

    cpdef SimpleInterval intersection_with(self, SimpleInterval other)

    cpdef complement(self)

    cpdef bint contains(self, float item) except *

    cdef str non_empty_to_string(self)

    cpdef float center(self) except *

cdef class Interval:
    cdef CPPInterval* cpp_object

    # cdef const CPPAbstractCompositeSetPtr_t as_cpp_composite_set(self)

    cdef Interval from_cpp_interval(self, CPPIntervalPtr_t composite_set)

    cdef from_cpp_composite_set_set(self, SimpleSetSetPtr_t si)


    cpdef Interval simplify(self)

    cpdef Interval new_empty_set(self)

    cpdef Interval complement_if_empty(self)

    cpdef bint is_singleton(self)
