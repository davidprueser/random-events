from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.sigma_algebra_cpp cimport CPPAbstractSimpleSetPtr_t, CPPAbstractSimpleSet, CPPAbstractCompositeSetPtr_t, CPPAbstractCompositeSet, SimpleSetSetPtr_t
from random_events.set_cpp cimport CPPSetElement, CPPAllSetElementsPtr_t, CPPSetElementPtr_t, CPPAllSetElements_t, CPPSet
from libcpp.memory cimport shared_ptr, make_shared

cdef class SetElement(AbstractSimpleSet):
    cdef CPPSetElement *cpp_set_element_object
    cdef public element
    cdef public all_elements
    cdef public int index
    cdef public int length

    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set)

    cpdef bint contains(self, item)

    cpdef bint is_empty(self)

    cpdef str non_empty_to_string(self)

    cpdef AbstractCompositeSet as_composite_set(self)

    cpdef to_json(self)


cdef class Set(AbstractCompositeSet):
    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set)

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set)

    cdef from_cpp_composite_set_set(self, SimpleSetSetPtr_t composite_set)

    cpdef Set complement_if_empty(self)

    cpdef Set simplify(self)

    cpdef Set new_empty_set(self)

    cpdef Set make_disjoint(self)

    cpdef to_json(self)