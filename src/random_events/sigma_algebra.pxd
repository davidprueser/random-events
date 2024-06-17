cdef class AbstractSimpleSet:
    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other) except *
    cpdef bint is_empty(self) except *
    cpdef bint contains(self, float item) except *