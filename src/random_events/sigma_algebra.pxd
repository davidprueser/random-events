from random_events.sigma_algebra_cpp cimport (CPPAbstractSimpleSet, CPPAbstractCompositeSet, SimpleSetSetPtr_t,
        CPPAbstractSimpleSetPtr_t, CPPAbstractCompositeSetPtr_t, SimpleSetSet_t, ElementaryVariant)
from libcpp.set cimport set as cppset
from libcpp.memory cimport shared_ptr
from libc.stdio cimport printf
from libcpp.utility cimport pair


cdef class AbstractSimpleSet:
    cdef CPPAbstractSimpleSet *cpp_object
    cdef public json_serializer

    cdef const CPPAbstractSimpleSetPtr_t as_cpp_simple_set(self)

    cdef const SimpleSetSetPtr_t as_cpp_simple_set_set(self)

    cdef AbstractSimpleSet from_cpp_si(self, CPPAbstractSimpleSetPtr_t simple_set)

    cdef set[AbstractSimpleSet] from_cpp_simple_set_set(self, SimpleSetSetPtr_t simple_set_set)

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)

    cpdef complement(self)

    cpdef bint is_empty(self) except *

    cpdef bint contains(self, item) except *

    cdef str non_empty_to_string(self)

    cpdef difference_with(self, AbstractSimpleSet other)

    cpdef str to_string(self)

    cpdef AbstractCompositeSet as_composite_set(self)


cdef class AbstractCompositeSet:
    cdef CPPAbstractCompositeSet *cpp_object
    cdef public json_serializer
    cdef public simple_sets

    cdef const CPPAbstractCompositeSetPtr_t as_cpp_composite_set(self)

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set)

    cdef from_cpp_composite_set_set(self, SimpleSetSetPtr_t composite_set_set)


    cpdef AbstractCompositeSet simplify(self)

    cpdef AbstractCompositeSet new_empty_set(self)

    cpdef AbstractCompositeSet union_with(self, AbstractCompositeSet other)

    cpdef AbstractCompositeSet intersection_with_simple_set(self, AbstractSimpleSet other)

    cpdef AbstractCompositeSet intersection_with_simple_sets(self, set_of_simple_sets)

    cpdef AbstractCompositeSet intersection_with(self, AbstractCompositeSet other)

    cpdef AbstractCompositeSet difference_with_simple_set(self, AbstractSimpleSet other)

    cpdef AbstractCompositeSet difference_with_simple_sets(self, other)

    cpdef AbstractCompositeSet difference_with(self, AbstractCompositeSet other)

    cpdef AbstractCompositeSet complement(self)

    cpdef AbstractCompositeSet complement_if_empty(self)

    cpdef bint is_empty(self)

    cpdef bint contains(self, item)

    cpdef str to_string(self)

    cpdef bint is_disjoint(self)

    # cdef tuple[AbstractCompositeSet, AbstractCompositeSet] split_into_disjoint_and_non_disjoint(self)

    cpdef AbstractCompositeSet make_disjoint(self)