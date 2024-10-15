from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet

cdef class SetElement(AbstractSimpleSet):
    cdef public int element
    cdef public all_elements

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)

    cpdef complement(self)

    cpdef bint is_empty(self)

    cpdef bint contains(self, item)

    cpdef str non_empty_to_string(self)

    cpdef AbstractCompositeSet as_composite_set(self)


cdef class Set(AbstractCompositeSet):
    cpdef Set complement_if_empty(self)

    cpdef Set simplify(self)

    cpdef Set new_empty_set(self)

    cpdef Set make_disjoint(self)

    cpdef AbstractCompositeSet complement(self)