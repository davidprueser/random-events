from random_events.simple_interval cimport CPPAbstractSimpleSet, CPPSimpleInterval
from libcpp.set cimport set as cppset

cdef class AbstractSimpleSet:
    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)

    cdef complement(self)

    cpdef bint is_empty(self) except *

    cpdef bint contains(self, float item) except *

    # cpdef str non_empty_to_string(self)

    cpdef difference_with(self, AbstractSimpleSet other)

    cpdef str to_string(self)

    cpdef AbstractCompositeSet as_composite_set(self)


cdef class AbstractCompositeSet:
    cdef cppset[CPPAbstractSimpleSet] simple_sets

    cpdef AbstractCompositeSet simplify(self)

    cpdef AbstractCompositeSet new_empty_set(self)

    cpdef AbstractCompositeSet union_with(self, AbstractCompositeSet other)

    cdef AbstractCompositeSet intersection_with_simple_set(self, AbstractSimpleSet other)

    cdef AbstractCompositeSet intersection_with_simple_sets(self, other)

    cpdef AbstractCompositeSet intersection_with(self, AbstractCompositeSet other)

    cdef AbstractCompositeSet difference_with_simple_set(self, AbstractSimpleSet other)

    cdef AbstractCompositeSet difference_with_simple_sets(self, other)

    cpdef AbstractCompositeSet difference_with(self, AbstractCompositeSet other)

    cdef AbstractCompositeSet complement(self)

    cpdef AbstractCompositeSet complement_if_empty(self)

    cpdef bint is_empty(self)

    cpdef bint contains(self, float item)

    cpdef str to_string(self)

    cpdef bint is_disjoint(self)

    cdef split_into_disjoint_and_non_disjoint(self)

    cpdef AbstractCompositeSet make_disjoint(self)

    cdef void add_simple_set(self, AbstractSimpleSet simple_set)
