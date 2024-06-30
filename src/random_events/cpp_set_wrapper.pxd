from libcpp.set cimport set
from cpython.ref cimport PyObject
cimport cython

from random_events.interval import SimpleInterval


cdef extern from "<functional>" namespace "std":
    cdef cppclass less[T]:
        less() except +

cdef extern from "<memory>" namespace "std":
    cdef cppclass shared_ptr[T]:
        shared_ptr() except +

cdef extern from "<functional>" namespace "std":
    cdef cppclass function[RetType, Args]:
        function() except +

cdef class SetWrapper:
    cdef set[shared_ptr[SimpleInterval]] cpp_set

    cdef void insert(self, SimpleInterval obj)

    cdef size_t size(self)
