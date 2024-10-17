from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.sigma_algebra_cpp cimport CPPAbstractSimpleSetPtr_t, CPPAbstractSimpleSet, CPPAbstractCompositeSetPtr_t, CPPAbstractCompositeSet
from random_events.set_cpp cimport CPPSetElement, CPPAllSetElementsPtr_t, CPPSetElementPtr_t, CPPAllSetElements_t
from libcpp.memory cimport shared_ptr, make_shared

cdef class SetElement(AbstractSimpleSet):
    cdef CPPSetElement *cpp_set_element_object
    cdef public str element
    cdef public all_elements

    cdef AbstractSimpleSet from_cpp_si(self, CPPAbstractSimpleSetPtr_t simple_set)
    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)

    cpdef complement(self)

    cpdef bint is_empty(self)

    cpdef bint contains(self, item)

    cpdef str non_empty_to_string(self)

    cpdef AbstractCompositeSet as_composite_set(self)

    cpdef to_json(self)


cdef class Set(AbstractCompositeSet):
    cpdef Set complement_if_empty(self)

    cpdef Set simplify(self)

    cpdef Set new_empty_set(self)

    cpdef Set make_disjoint(self)

    cpdef AbstractCompositeSet complement(self)

    cpdef to_json(self)