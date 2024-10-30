from random_events.sigma_algebra cimport AbstractCompositeSet


cdef class Variable:
    cdef public str name
    cdef public AbstractCompositeSet domain
    cdef public json_serializer